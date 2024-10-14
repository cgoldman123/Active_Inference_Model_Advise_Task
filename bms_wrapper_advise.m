% Wrapper for bayesian model selection with spm_BMS
input_file = 'L:/rsmith/lab-members/ttakahashi/WellbeingTasks/AdviceTask/output.csv';
output_file = 'L:/rsmith/lab-members/ttakahashi/WellbeingTasks/AdviceTask/';
addpath('L:/rsmith/all-studies/util/spm12/');

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


writetable(results_table, fullfile(output_file, 'model_comparison_results_advicetask.csv'));
