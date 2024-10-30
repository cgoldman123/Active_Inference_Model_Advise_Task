
import os
import re
import csv
from datetime import datetime

# Define the directory path for input files and output file
directory_path = "/mnt/dell_storage/labs/NPC/DataSink/StimTool_Online/WB_Advice"  # Replace with your directory path
output_directory = "/mnt/dell_storage/labs/rsmith/lab-members/fli/advise_task/subject_id/"    # Replace with your output directory

# Create a timestamped output file name

output_file = os.path.join(output_directory, f"subject_ids.csv")

# Regular expression to extract subject ID after 'active_trust_'
pattern = re.compile(r"active_trust_([a-zA-Z0-9]+)_")

# Set to store unique subject IDs
unique_ids = set()

# Loop through each file in the directory
for filename in os.listdir(directory_path):
    # Check if the file matches the pattern
    match = pattern.search(filename)
    if match:
        subject_id = match.group(1)
        # Add the subject ID to the set (duplicates will be ignored)
        unique_ids.add(subject_id)

# Write unique subject IDs to the CSV file with column name 'id'
with open(output_file, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    # Write the header
    writer.writerow(["id"])
    # Write each unique subject ID
    for subject_id in unique_ids:
        writer.writerow([subject_id])

print(f"Unique subject IDs have been written to {output_file} as a CSV file with column name 'id'")