# Road Anomaly Detection, Classification and Mapping - RADCM

## Some basic directory structure
All the android app stuff will go in App/   
All the backend stuff, including django folders and all the ml stuff too, will go in Server/  
All the code to be run on the mpu6050 module will go in Mpu6050Module/  
... you get the idea   

## Datasets
To download the datasets on your local machine, run the GetDataset notebook.  
To add your own dataset to the collection, upload the dataset to drive, and add the corrosponding code to the GetDataset notebook.  
### Expected file structure of dataset: 
-train 
--labels.csv -> containing tuples of the form: (path to csv file with data, class name)
--datax.csv -> containing individual anomaly data, where x is a number ranging from 0 to len(labels.csv)
-test
 (same as train)
