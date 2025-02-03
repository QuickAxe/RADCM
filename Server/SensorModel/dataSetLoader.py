# code to return a data loader to load the dataset in a pytorch dataset format (duh)
import os
import pandas as pd
import numpy as np
import os

from torch.utils.data import DataLoader, Dataset


class SensorData(Dataset):
    """Dataset of sensor data"""

    def __init__(self, annotationsFile, anomaliesDir):
        """annotationsFile: Path to the csv file that has the labels and where they're stored
        anomaliesDir: Path to where the actual data is stored"""

        self.anomalyLabels = pd.read_csv(annotationsFile)
        self.anomaliesDir = anomaliesDir

    def __len__(self):
        return len(self.anomalyLabels)

    def __getitem__(self, idx):
        anomalyPath = os.path.join(self.anomaliesDir, self.anomalyLabels.iloc[idx, 0])

        # read the anomaly data and convert it to a numpy array:
        anomaly = pd.read_csv(anomalyPath)
        anomaly = anomaly.to_numpy(dtype=np.float32, copy=True)

        anomaly = np.transpose(anomaly)

        anomaly = anomaly[None, :, :]
        # print(anomaly.dtype)

        # load its label too
        label = self.anomalyLabels.iloc[idx, 1]

        # return a tuple of anomaly array, label
        #! I think this might have to be converted to a tensor
        return (anomaly, label)
