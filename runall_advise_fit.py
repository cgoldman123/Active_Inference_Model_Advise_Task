import sys, os, re, subprocess

subject_list_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_subject_IDs.csv'
input_directory = sys.argv[1]
results = sys.argv[2]

if not os.path.exists(results):
    os.makedirs(results)
    print(f"Created results directory {results}")

if not os.path.exists(f"{results}/logs"):
    os.makedirs(f"{results}/logs")
    print(f"Created results-logs directory {results}/logs")

subjects = []
with open(subject_list_path) as infile:
    for line in infile:
        if 'ID' not in line:
            subjects.append(line.strip())

ssub_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/advise_task/current_scripts/run_advise_fit.ssub'

for subject in subjects:
    stdout_name = f"{results}/logs/{subject}-%J.stdout"
    stderr_name = f"{results}/logs/{subject}-%J.stderr"

    jobname = f'advise-fit-{subject}'
    os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {subject} {input_directory} {results}")

    print(f"SUBMITTED JOB [{jobname}]")


    ###python3 runall_advise_fit.py /media/labs/rsmith/wellbeing/tasks/AdviceTask/behavioral_files_2-6-24 /media/labs/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_fits_corrected_combined_learning_forgetting