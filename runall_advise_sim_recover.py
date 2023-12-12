import sys, os, re, random, csv


# run all for simulating and fitting a bunch of params

results = sys.argv[1]


if not os.path.exists(results):
    os.makedirs(results)
    print(f"Created results directory {results}")

if not os.path.exists(f"{results}/logs"):
    os.makedirs(f"{results}/logs")
    print(f"Created results-logs directory {results}/logs")



ssub_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/advise_task/recoverability/recoverability_scripts/run_advise.ssub'

for sim_id in range(100):
    #alpha = random.uniform(.5, 12)
    p_ha = random.uniform(.02, .98)
    #prior_a = random.uniform(2, 10)
    #omega_context = random.uniform(.2, 1)
    #rs = random.uniform(3.5, 8.5)
    #la = random.uniform(0 + 1e-7, 4 - 1e-7)
    omega_advisor_win = random.uniform(.2, 1)
    omega_advisor_loss = random.uniform(.2, 1)

    stdout_name = f"{results}/logs/{sim_id}-%J.stdout"
    stderr_name = f"{results}/logs/{sim_id}-%J.stderr"

    jobname = f'advise-recoverability-{sim_id}'
    os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {results} {sim_id} {p_ha} {omega_advisor_win} {omega_advisor_loss}")

    print(f"SUBMITTED JOB [{jobname}]")
    sim_id = sim_id+1





# param_folder_path = '/media/labs/rsmith/lab-members/cgoldman/Wellbeing/advise_task/scripts/mturk_fits_output'

# # Iterate over each CSV file in the directory
# for csv_file in os.listdir(param_folder_path):
#     if csv_file.endswith('.csv'):
#         file_path = os.path.join(param_folder_path, csv_file)
        
#         # Open and read the CSV file
#         with open(file_path, mode='r') as infile:
#             reader = csv.DictReader(infile)
            
#             # Iterate over each row in the CSV
#             for row in reader:
#                 alpha = row['alpha']
#                 omega = row['omega']
#                 prior_a = row['prior_a']
#                 la = row['la']
#                 p_ha = row['p_ha']
#                 subject = row['subject']

#     stdout_name = f"{results}/logs/{subject}-%J.stdout"
#     stderr_name = f"{results}/logs/{subject}-%J.stderr"

#     jobname = f'advise-recoverability-{subject}'
#     os.system(f"sbatch -J {jobname} -o {stdout_name} -e {stderr_name} {ssub_path} {results} {subject} {alpha} {p_ha} {prior_a} {omega} {la}")

#     print(f"SUBMITTED JOB [{jobname}]")







