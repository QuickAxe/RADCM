import json
import os
import glob
import uuid
import csv

sample_num = 200

# Spanish to English mapping
s2e = {
    "Bordo" : "Breaker",
    "Bache" : "Pothole",
}

for label in s2e.values():
    os.makedirs(label, exist_ok = True)

json_files = glob.glob(os.path.join("./", "*.json"))

with open("labels.csv",'a') as label_csv_file:
    label_writer = csv.writer(label_csv_file)
    
    for json_file in json_files:
        with open(json_file) as f:
            data = json.load(f)

        for anomaly in data['anomalies']:
            if anomaly["type"] in s2e:
                label = s2e[anomaly["type"]]
                file_name = str(uuid.uuid4())+".csv"
                
                mid_point = (anomaly["start"] + anomaly["end"])//2
                
                with open(os.path.join("./",f"{label}",f"{file_name}"),'w') as sample_csv_file:
                    sample_writer = csv.writer(sample_csv_file)
                    
                    for rows in range(mid_point - (sample_num)//2 + 1, mid_point + (sample_num)//2 + 1):
                        acc_x = data['rot_acc_x'][rows]
                        acc_y = data['rot_acc_y'][rows]
                        acc_z = data['rot_acc_z'][rows]
                        sample_writer.writerows([[f'{acc_x}', f'{acc_y}', f'{acc_z}']])
                    
                
                label_writer.writerows([[f"./{label}/{file_name}", f"{label}"]])
            
    
