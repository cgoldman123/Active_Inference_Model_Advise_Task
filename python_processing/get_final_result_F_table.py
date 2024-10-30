import os
import pandas as pd
import re

# Define path to your files
path = '/mnt/dell_storage/labs/rsmith/lab-members/fli/advise_task/results/'

# Initialize the dictionary to store UUIDs and their F values for 10 indexes
uuid_dict = {}

# Define a regex pattern to match file names and capture the uuid and idx
pattern = re.compile(r"advice_task_model_identification_([a-fA-F0-9\-]+)_(\d+)\.csv")

# Iterate over all files in the directory
for file_name in os.listdir(path):
    match = pattern.match(file_name)
    if match:
        # Extract UUID and index from the file name
        uuid = match.group(1)
        idx = int(match.group(2))
        
        # Ensure the UUID is in the dictionary with a 10-element array initialized to 0
        if uuid not in uuid_dict:
            uuid_dict[uuid] = [0] * 10

        # Read the file
        file_path = os.path.join(path, file_name)
        df = pd.read_csv(file_path)

        # Extract the F value from the last column, second row (index 1)
        f_value = df.iloc[1, -1]

        # Assign the F value to the correct index in the dictionary
        uuid_dict[uuid][idx-1] = f_value

# Convert the dictionary to a DataFrame
output_df = pd.DataFrame.from_dict(uuid_dict, orient="index", columns=[f"idx_{i}" for i in range(1,11)])

# Save the output to a CSV file
output_csv_path = os.path.join(path, "final_res/output_f_values.csv")
output_df.to_csv(output_csv_path, index_label="uuid")

print(f"Output saved to {output_csv_path}")