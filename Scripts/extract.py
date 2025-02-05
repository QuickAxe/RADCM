# Helper script to extract event windows from dataset

import pandas as pd
import os
import uuid
import glob

csv_directory = "./"

target_values = {0: "Flat", 1: "Pothole", 2: "Breaker"}
target_column_idx = -1

labels = []

for label in target_values.values():
    if not os.path.exists(label):
        os.makedirs(label)

csv_files = glob.glob(os.path.join(csv_directory, "*.csv"))

for csv_file in csv_files:
    # print(f"File: {csv_file}")
    
    df = pd.read_csv(csv_file, header=None)
    
    column_indices = [0, 1, 2, 20]
    df = df.iloc[:, column_indices]

    for target_value, label in target_values.items():
        target_indices = df[df.iloc[:, target_column_idx] == target_value].index

        # Helpful to check if things are messed up
        if len(target_indices) == 0:
            print(f"Target value {target_value} ({label}) not found!!!!.")
            continue

        groups = []
        current_group = [target_indices[0]]

        for i in range(1, len(target_indices)):
            if target_indices[i] == target_indices[i - 1] + 1:
                current_group.append(target_indices[i])
            else:
                groups.append(current_group)
                current_group = [target_indices[i]]
        groups.append(current_group)

        for group_idx, group in enumerate(groups):
            start_idx = group[0]
            end_idx = group[-1]

            window_df = df.iloc[start_idx:end_idx + 1]

            middle_idx = start_idx + (len(window_df) // 2)

            final_start_idx = max(0, middle_idx - 99)
            final_end_idx = min(len(df), middle_idx + 100)

            final_df = df.iloc[final_start_idx:final_end_idx + 1]
            if final_end_idx - final_start_idx != 199:
                continue
            
            final_df.pop(final_df.columns[-1])    
            output_folder = label
            file_name = f"{output_folder}/{uuid.uuid4()}.csv"

            final_df.to_csv(file_name, index=False, header=False)

            labels.append([file_name, label])

labels_df = pd.DataFrame(labels, columns=["filePath", "classLabel"])
labels_df.to_csv("labels.csv", mode='a', index=False, header=False)

