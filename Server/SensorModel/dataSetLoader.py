# code to return a data loader to load the dataset in a pytorch dataset format (duh)
# most of the stuff comes from here: https://pytorch.org/tutorials/beginner/data_loading_tutorial.html
import os
import pandas as pd
import numpy as np
import os

import torch
from torch.utils.data import Dataset
from torch.nn.functional import normalize

class SensorData(Dataset):
    """Dataset of sensor data"""

    def __init__(self, annotationsFile, anomaliesDir, transform=None):
        """annotationsFile: Path to the csv file that has the labels and where they're stored
        anomaliesDir: Path to where the actual data is stored"""

        self.anomalyLabels = pd.read_csv(annotationsFile)
        self.anomaliesDir = anomaliesDir

        # a dict to store the mapping of the labels to an int value 
        self.labels = {"Pothole": 0, "Breaker": 1, "Flat": 2}

        self.transform = transform

    def __len__(self):
        return len(self.anomalyLabels)

    def __getitem__(self, idx):
        anomalyPath = os.path.join(self.anomaliesDir, self.anomalyLabels.iloc[idx, 0])

        # read the anomaly data and convert it to a numpy array:
        anomaly = pd.read_csv(anomalyPath, header=None)
        anomaly = anomaly.to_numpy(dtype=np.float32, copy=True)

        anomaly = anomaly.transpose()
                
        # perfrom transforms, if any passed during init
        if self.transform:
            anomaly = self.transform(anomaly)
        
        # print(anomaly)

        anomaly = torch.tensor(anomaly)
        anomaly = normalize(anomaly)
        
        # add an extra dim here, to represent the number of channels 
        anomaly = anomaly[None, :, :]

        # load its label too
        label = self.anomalyLabels.iloc[idx, 1]
        # convert label to int
        label = self.labels[label]

        # return a tuple of anomaly array, label
        return (anomaly, label)
