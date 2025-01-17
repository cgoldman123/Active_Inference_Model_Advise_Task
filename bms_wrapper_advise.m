% Wrapper for bayesian model selection with spm_BMS

% ROOT:
% If ROOT is not assigned (i.e., empty), the script will derive the root 
% path based on the location of the main file.
ROOT = ''; 
% ROot = L:/rsmith/lab-members/ttakahashi/WellbeingTasks/AdviceTask

% Detect the system
% 'pc' for Windows, 'mac' for local Mac, 'cluster' for running on VM cluster
env_sys = '';
if ispc
    env_sys = 'pc';
elseif ismac
    env_sys = 'mac';
elseif isunix
    env_sys = 'cluster';
else
    disp('Unknown operating system.');
end

if isempty(ROOT)
    ROOT = fileparts(mfilename('fullpath'));
    disp(['ROOT path set to: ', ROOT]);
end
% Add external paths depending on the system
if strcmp(env_sys, 'pc')
    spmPath = '/output.csv';

elseif strcmp(env_sys, 'mac')
    spmPath =  [ ROOT '/spm/'];
elseif strcmp(env_sys, 'cluster')
    spmPath = '/mnt/dell_storage/labs/rsmith/all-studies/util/spm12';

end

addpath(spmPath);

% input_file = 'L:/rsmith/lab-members/ttakahashi/WellbeingTasks/AdviceTask/output.csv';
input_file = '/mnt/dell_storage/labs/rsmith/lab-members/fli/advise_task/results/final_res/output_f_values.csv'
% output_file = 'L:/rsmith/lab-members/ttakahashi/WellbeingTasks/AdviceTask/';
output_folder_path = '/mnt/dell_storage/labs/rsmith/lab-members/fli/advise_task/results/final_res/';
% addpath('L:/rsmith/all-studies/util/spm12/');

allData = readtable(input_file);
% Select all columns except the first one (contains IDs)
selectedColumns = allData(:, 2:end);
lme = table2array(selectedColumns);
Nsamp = size(lme,1);

[alpha,exp_r,xp,pxp,bor] = spm_BMS(lme, Nsamp,1);
results_table = table;
results_table.model = (1:size(lme,2))';
results_table.alpha = alpha';
results_table.exp_r = exp_r';
results_table.xp = xp';
results_table.pxp = pxp';
results_table.bor = repmat(bor,size(lme,2),1);


writetable(results_table, fullfile(output_folder_path, 'model_identifiability_results_advicetask.csv'));
