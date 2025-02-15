import torch
from torch.utils.data import DataLoader
import os
import csv
from tqdm import tqdm
import matplotlib.pyplot as plt
import pandas as pd

# from torch.utils.tensorboard import SummaryWriter
import numpy as np
from models import CnnLSTM

from dataSetLoader import SensorData
from transforms import Interpolate

from tqdm import tqdm

# ================================== initialising ========================================

# comment out if not on a apple device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Device: ", device)

# =========================== initilaise the dataloaders =================================

#! determine a good smoothing factor
interpolateTransform = Interpolate(interpolateFactor=5, smoothingFactor=30)

validationSet = SensorData(
    "./../Datasets/sensorDataset/test/labels.csv", "./../Datasets/sensorDataset/test/", transform=interpolateTransform
)

trainSet = SensorData(
    "./../Datasets/sensorDataset/train/labels.csv", "./../Datasets/sensorDataset/train/", transform=interpolateTransform
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

model = CnnLSTM(16, 3, 3)

model = model.to(device)

lossFunction = torch.nn.CrossEntropyLoss().to(device)
optimiser = torch.optim.Adam(model.parameters(), lr=0.001)


# helper function to train model
def train_one_epoch(epoch_index):
    running_loss = 0.0
    last_loss = 0.0

    # Here, we use enumerate(training_loader) instead of
    # iter(training_loader) so that we can track the batch
    # index and do some intra-epoch reporting
    # for i_ in tqdm(range(0, len(trainingDataloader))):
    for i, data in enumerate(tqdm(trainingDataloader)):
        # Every data instance is an input + label pair

        inputs, labels = data
        
        inputs = inputs.to(device)
        labels = labels.to(device)

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
        # print("  batch {} loss: {}".format(i + 1, running_loss))
        running_loss = 0.0

    return last_loss / len(trainingDataloader)


# =================================== actual training loop ======================================
EPOCHS = 1

best_vloss = 1_000_000.0

os.makedirs("./runs", exist_ok=True)
with open("./runs/results.csv", "a") as f:
    writer = csv.writer(f)
    writer.writerow(["Epoch", "Train_Loss", "Val_Loss"])

    for epoch in range(EPOCHS):
        print("EPOCH {}:".format(epoch + 1))

        # Make sure gradient tracking is on, and do a pass over the data
        model.train(True)
        avg_loss = train_one_epoch(epoch)

        running_vloss = 0.0
        # Set the model to evaluation mode, disabling dropout and using population
        # statistics for batch normalization.
        model.eval()

        # Disable gradient computation and reduce memory consumption.
        with torch.no_grad():
            for i, vdata in enumerate(validationDataloader):
                vinputs, vlabels = vdata
                vinputs = vinputs.to(device)
                vlabels = vlabels.to(device)
                
                voutputs = model(vinputs)
                vloss = lossFunction(voutputs, vlabels)
                running_vloss += vloss

        avg_vloss = running_vloss / len(validationDataloader)
        running_vloss = 0.0
        print(
            "EPOCH {} Losses: train {} valid {}".format(epoch + 1, avg_loss, avg_vloss),
            end="\n\n",
        )
        writer.writerow([epoch + 1, avg_loss, avg_vloss.item()])

        # Log the running loss averaged per batch
        # for both training and validation
        # writer.add_scalars(
        #     "Training vs. Validation Loss",
        #     {"Training": avg_loss, "Validation": avg_vloss},
        #     epoch_number + 1,
        # )
        # writer.flush()

        # Track best performance, and save the model's state

        if epoch % 10 == 0:
            model_path = "./runs/model_{}.pt".format(epoch + 1)
            torch.save(model.state_dict(), model_path)
            f.flush()

filePath = "./runs/results.csv"
df = pd.read_csv(filePath)

x = df.iloc[:, 0]
y1 = df.iloc[:, 1]
y2 = df.iloc[:, 2]

plt.figure(figsize=(10, 5))
plt.plot(x, y1, "r-", label="Train Loss")
plt.plot(x, y2, "b-", label="Val Loss")

plt.xlabel("Epoch")
plt.ylabel("Values")
plt.legend()
plt.grid(True)

plt.savefig("./runs/results.png", dpi=300, bbox_inches="tight")
plt.close()
