import torch
import torch.optim.rmsprop
from torch.utils.data import DataLoader
import os
import csv
from tqdm import tqdm
import matplotlib.pyplot as plt
import pandas as pd

# import numpy as np
from models import *

from dataSetLoader import SensorData
from transforms import Interpolate

from tqdm import tqdm


#! =================================================== Parameters ==========================================================

# need I explain these?
batchSize = 64
EPOCHS = 100

# the factor to smoothen the interpolated data by, duh!
#! determine a good smoothing factor
smoothingFactor = 0

# the number of times to increase the data samples by,
# eg 200 data samples with a factor of 5 will output 1000 interpolated data samples
interpolationFactor = 5

# number of cpu workers to assign to the dataloader (more is better, but make sure your cpu has enough threads)
# ! Ok I'm not entirely sure how this works, so maybe leave it at 0
numWorkers = 0

# run number to save to its corresponding folder (yes yes, I know, but I'm too lazy to do this in code automatically)
runNo = "Cnn5-Carlos75TEST"


# ================================================== initialising =========================================================

device = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else ("mps" if torch.mps.is_available() else "cpu")
)
print("Device: ", device)

# ------------------------------ initilaise the dataloaders ------------------------------

interpolateTransform = Interpolate(
    interpolateFactor=interpolationFactor, smoothingFactor=smoothingFactor
)


validationSet = SensorData(
    "./../Datasets/sensorDataset/test/labels.csv",
    "./../Datasets/sensorDataset/test/",
    transform=interpolateTransform,
)

trainSet = SensorData(
    "./../Datasets/sensorDataset/train/labels.csv",
    "./../Datasets/sensorDataset/train/",
    transform=interpolateTransform,
)

validationDataloader = DataLoader(
    validationSet,
    batch_size=batchSize,
    shuffle=False,
    num_workers=numWorkers,
    pin_memory=True,
)

trainingDataloader = DataLoader(
    trainSet,
    batch_size=batchSize,
    shuffle=True,
    num_workers=numWorkers,
    pin_memory=True,
)

print("Training set has {} instances".format(len(trainSet)))
print("Validation set has {} instances".format(len(validationSet)))

# attempting to load all the data to device in one shot
# ! this did nothing :(
# for data, target in validationDataloader:
#     data = data.to('cuda')
#     target = target.to('cuda')

# for data, target in trainingDataloader:
#     data = data.to('cuda')
#     target = target.to('cuda')

# =============================================== training loop part now ================================================

# model = CnnLSTM(256, 3, 2)
model = Cnn5(2)

model = model.to(device)

lossFunction = torch.nn.CrossEntropyLoss()
# optimiser = torch.optim.Adam(model.parameters(), lr=0.001)
optimiser = torch.optim.RMSprop(model.parameters(), lr=0.001, weight_decay=0.0001)


# helper function to train model
def train_one_epoch(epoch_index):
    running_loss = 0.0

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
        print(outputs)

        # Compute the loss and its gradients
        loss = lossFunction(outputs, labels)
        # print(loss)
        loss.backward()

        # Adjust learning weights
        optimiser.step()

        # Gather data and report
        running_loss += loss.item()

        # last_loss += running_loss  # loss per batch
        # # print("  batch {} loss: {}".format(i + 1, running_loss))
        # running_loss = 0.0

    return running_loss / len(trainingDataloader)


# ================================================== actual training loop ================================================
def train():

    best_vloss = 1_000_000.0

    os.makedirs(f"./runs{runNo}", exist_ok=True)

    # with open("./runs1/results.csv", "a") as f:
    #     writer = csv.writer(f)
    # writer.writerow(["Epoch", "Train_Loss", "Val_Loss"])

    writerList = [["Epoch", "Train_Loss", "Val_Loss"]]

    for epoch in range(EPOCHS):
        print("EPOCH {}:".format(epoch + 1))

        # Make sure gradient tracking is on, and do a pass over the data
        model.train(True)
        avg_loss = train_one_epoch(epoch)

        running_vloss = 0.0

        # Set the model to evaluation mode, disabling dropout and using population
        # statistics for batch normalization.
        model.eval()

        correct = 0
        # Disable gradient computation and reduce memory consumption.
        with torch.no_grad():
            for i, vdata in enumerate(validationDataloader):
                vinputs, vlabels = vdata

                vinputs = vinputs.to(device)
                vlabels = vlabels.to(device)

                voutputs = model(vinputs)
                vloss = lossFunction(voutputs, vlabels)
                correct += (
                    (voutputs.argmax(1) == vlabels).type(torch.float).sum().item()
                )
                running_vloss += vloss

        avg_vloss = running_vloss / len(validationDataloader)
        running_vloss = 0.0
        correct /= len(validationDataloader.dataset)

        print(
            "EPOCH {} Losses: train {} valid {} Accuracy: {}%".format(
                epoch + 1, avg_loss, avg_vloss, (100 * correct)
            ),
            end="\n\n",
        )

        # writer.writerow([epoch + 1, avg_loss, avg_vloss.item()])
        writerList.append([epoch + 1, avg_loss, avg_vloss.item()])

        # Log the running loss averaged per batch
        # for both training and validation
        # writer.add_scalars(
        #     "Training vs. Validation Loss",
        #     {"Training": avg_loss, "Validation": avg_vloss},
        #     epoch_number + 1,
        # )
        # writer.flush()

        # Track best performance, and save the model's state
        if epoch % 10 == 9:
            model_path = "./runs{}/model_{}.pt".format(runNo, epoch + 1)
            torch.save(model.state_dict(), model_path)
            # f.flush()

    with open(f"./runs{runNo}/results.csv", "a") as f:
        writer = csv.writer(f)
        writer.writerows(writerList)
        f.flush()

    filePath = f"./runs{runNo}/results.csv"
    df = pd.read_csv(filePath)

    x = df.iloc[5:, 0]
    y1 = df.iloc[5:, 1]
    y2 = df.iloc[5:, 2]

    plt.figure(figsize=(10, 5))
    plt.plot(x, y1, "r-", label="Train Loss")
    plt.plot(x, y2, "b-", label="Val Loss")

    plt.xlabel("Epoch")
    plt.ylabel("Values")
    plt.legend()
    plt.grid(True)

    plt.savefig(f"./runs{runNo}/results.png", dpi=300, bbox_inches="tight")
    plt.close()


if __name__ == "__main__":
    train()
