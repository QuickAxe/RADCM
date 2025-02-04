import torch
from torch.utils.data import DataLoader
from torch.utils.tensorboard import SummaryWriter
import numpy
from models import CnnLSTM
from datetime import datetime

from dataSetLoader import SensorData

# ================================== initialising ========================================

# device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# comment out if not on a apple device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Device: ", device)

# =========================== initilaise the dataloaders =================================

validationSet = SensorData(
    "./../Datasets/sensorDataset/test/labels.csv", "./../Datasets/sensorDataset/test/"
)

trainSet = SensorData(
    "./../Datasets/sensorDataset/train/labels.csv", "./../Datasets/sensorDataset/train/"
)

validationDataloader = DataLoader(
    validationSet, batch_size=32, shuffle=False, num_workers=0, pin_memory=True
)

trainingDataloader = DataLoader(
    trainSet, batch_size=32, shuffle=True, num_workers=0, pin_memory=True
)

print("Training set has {} instances".format(len(trainSet)))
print("Validation set has {} instances".format(len(validationSet)))

# ============================= training loop part now ============================================

model = CnnLSTM(16, 3, 2)

lossFunction = torch.nn.CrossEntropyLoss()
optimiser = torch.optim.Adam(model.parameters(), lr=0.001)


# helper function to train model
def train_one_epoch(epoch_index, tb_writer):
    running_loss = 0.0
    last_loss = 0.0

    # Here, we use enumerate(training_loader) instead of
    # iter(training_loader) so that we can track the batch
    # index and do some intra-epoch reporting
    for i, data in enumerate(trainingDataloader):
        # Every data instance is an input + label pair
        inputs, labels = data

        # Zero your gradients for every batch!
        optimiser.zero_grad()

        # Make predictions for this batch
        outputs = model(inputs)
        # print(outputs)

        # Compute the loss and its gradients
        loss = lossFunction(outputs, labels)
        # print(loss)
        loss.backward()

        # Adjust learning weights
        optimiser.step()

        # Gather data and report
        running_loss += loss.item()

        last_loss += running_loss  # loss per batch
        print("  batch {} loss: {}".format(i + 1, running_loss))
        running_loss = 0.0

    return last_loss / len(trainingDataloader)


# =================================== actual training loop ======================================
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
writer = SummaryWriter("runs/CnnLstm{}".format(timestamp))
epoch_number = 0

EPOCHS = 10

best_vloss = 1_000_000.0

for epoch in range(EPOCHS):
    print("EPOCH {}:".format(epoch_number + 1))

    # Make sure gradient tracking is on, and do a pass over the data
    model.train(True)
    avg_loss = train_one_epoch(epoch_number, writer)

    running_vloss = 0.0
    # Set the model to evaluation mode, disabling dropout and using population
    # statistics for batch normalization.
    model.eval()

    # Disable gradient computation and reduce memory consumption.
    with torch.no_grad():
        for i, vdata in enumerate(validationDataloader):
            vinputs, vlabels = vdata
            voutputs = model(vinputs)
            vloss = lossFunction(voutputs, vlabels)
            running_vloss += vloss

    avg_vloss = running_vloss / len(validationDataloader)
    running_vloss = 0.0
    print("FINAL EPOCH LOSS train {} valid {}".format(avg_loss, avg_vloss))

    # Log the running loss averaged per batch
    # for both training and validation
    writer.add_scalars(
        "Training vs. Validation Loss",
        {"Training": avg_loss, "Validation": avg_vloss},
        epoch_number + 1,
    )
    writer.flush()

    # Track best performance, and save the model's state
    if avg_vloss < best_vloss:
        best_vloss = avg_vloss
        model_path = "model_{}_{}".format(timestamp, epoch_number)
        torch.save(model.state_dict(), model_path)

    epoch_number += 1
