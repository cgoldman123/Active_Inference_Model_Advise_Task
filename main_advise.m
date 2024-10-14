% main script for fitting/simming behavior on the advise task
dbstop if error
rng('default');
clear all;


SIM = true; % Generate simulated behavior (if false and FIT == true, will fit to subject file data instead)
FIT = true; % Fit example subject data 'BBBBB' or fit simulated behavior (if SIM == true)
plot = true;
%indicate if prolific or local
local = false;

% Setup directories based on system
if ispc
    root = 'L:';
    results_dir = 'L:/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_fits_sandbox'; % Where the fit results will save
    FIT_SUBJECT = 'FENGTEST'; % 6544b95b7a6b86a8cd8feb88 6550ea5723a7adbcc422790b
    INPUT_DIRECTORY = [root '/NPC/DataSink/StimTool_Online/WB_Advice'];  % Where the subject file is located

else
    root = '/media/labs';
    FIT_SUBJECT = getenv('SUBJECT');
    results_dir = getenv('RESULTS');
    INPUT_DIRECTORY = getenv('INPUT_DIRECTORY');

end


fprintf([INPUT_DIRECTORY '\n']);
fprintf([FIT_SUBJECT '\n']);



addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);
addpath([root '/rsmith/lab-members/cgoldman/Active-Inference-Tutorial-Scripts-main']);

% Define all parameters passed into the model; specify which ones to fit in
% field
% Define all parameters passed into the model; specify which ones to fit in
% field
params.p_a = .8;
params.inv_temp = 4;
params.reward_value = 4;
params.l_loss_value = 4;
%params.omega = .2;
params.omega_d_win = .2;
params.omega_d_loss = .2;
params.omega_a_win = .2;
params.omega_a_loss = .2;
%params.omega_d = .2;
%params.omega_a = .2;
params.eta = .5;
%params.eta_d = .5;
%params.eta_d_win = .5;
%params.eta_d_loss = .5;
%params.eta_a = .5;
%params.eta_a_win = .5;
%params.eta_a_loss = .5;
params.state_exploration = 1;
params.parameter_exploration = 0;


field = {'p_a','inv_temp','reward_value','l_loss_value','omega_a_win','omega_a_loss','omega_d_win','omega_d_loss','eta'}; %those are fitted

    
if FIT
        if ~local
            [fit_results, DCM] = Advice_fit_prolific(FIT_SUBJECT, INPUT_DIRECTORY, params, field, plot);
        else
            [fit_results, DCM] = Advice_fit(FIT_SUBJECT, INPUT_DIRECTORY, params, field, plot);
        end
        
        %%% feed the fitted parameters into advise_sim
        
        
        %%% fit the simulated behavior using advise_sim_fit
        
        
        
        model_free_results = advise_mf(fit_results.file);
        
        
        mf_fields = fieldnames(model_free_results);
        for i=1:length(mf_fields)
            fit_results.(mf_fields{i}) = model_free_results.(mf_fields{i});      
        end
        
        writetable(struct2table(fit_results), [results_dir '/advise_task-' FIT_SUBJECT '_fits.csv']);
end

    
%end

    
    

saveas(gcf,[results_dir '/' FIT_SUBJECT '_fit_plot.png']);
save(fullfile([results_dir '/fit_results_' FIT_SUBJECT '.mat']), 'DCM');
                            
