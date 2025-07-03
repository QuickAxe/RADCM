<div align="center">
  <h1>Rosto Radar</h1>
  <h3>Road Anomaly Detection, Classification, and Mapping</h3>
</div>

<div align="center">

![App](https://github.com/user-attachments/assets/e9e9217d-b9b3-4acd-b25e-3b673c4b45b9)

</div>

## Overview

Rosto Radar is an automated system primarily using user's phones to map road anomalies like potholes, speed breakers, and rumble strips etc and delivers real-time alerts to users about newly identified anomalies and provides authorities with a dedicated interface for locating, navigating to, and resolving these issues efficiently.

## Working 

For a demo of the working of the app, visit: https://www.hensenjuang.com/ 

## Datasets

To download the datasets on your local machine, run the GetDataset notebook.  
To add your own dataset to the collection, upload the dataset to drive, and add the corrosponding code to the GetDataset notebook.

### Expected file structure of dataset:

-train
--labels.csv -> containing tuples of the form: (path to csv file with data, class name)
--datax.csv -> containing individual anomaly data, where x is a number ranging from 0 to len(labels.csv)
-test
(same as train)
