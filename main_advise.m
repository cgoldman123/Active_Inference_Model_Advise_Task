% Authors: TODO 2024
% 
% Main Script for fitting/simming behavior on the wellbeing advise task
% 
dbstop if error
rng('default');
clear all;

% SWITCHES
% True -> Generate simulated behavior
SIM = true;
% True -> Fit the behavior data into the model
FIT = true;
% True -> TODO
PLOT = false;
% True -> EXAMPLE SUBJECT
EG_SUBJECT = false;

% SETTINGS
% Subject identifier for the test or experiment
FIT_SUBJECT = '';
% ROOT:
% If ROOT is not assigned (i.e., empty), the script will derive the root 
% path based on the location of the main file.
ROOT = ''; 
% RES_PATH:
% If RES_PATH is not assigned (i.e., empty), it will be auto-generated relative to ROOT.
% If RES_PATH is a relative path, it will be appended to the ROOT path.
RES_PATH = '/mnt/dell_storage/labs/rsmith/lab-members/fli/advise_task/results';
% INPUT_PATH:
% The folder path where the subject file is located. If INPUT_PATH is a relative path,
% it will be appended to the ROOT path.
INPUT_PATH = '/mnt/dell_storage/labs/NPC/DataSink/StimTool_Online/WB_Advice';
% IDX_CANDIDATE:
% This will define which candidate (set of parameters) is currently in use
% Modify this value to switch between different candidates (1 to 10 in this case)
IDX_CANDIDATE = 0; % Default to candidate 1, can be changed dynamically



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


% Path pre-processing
if isempty(ROOT)
    ROOT = fileparts(mfilename('fullpath'));
    disp(['ROOT path set to: ', ROOT]);
end

if isempty(FIT_SUBJECT)
    % Read from environment variable if empty
    FIT_SUBJECT = getenv('FIT_SUBJECT');
end

IDX_CANDIDATE = 0;

if IDX_CANDIDATE < 1 || IDX_CANDIDATE > 10
    env_value = getenv('IDX_CANDIDATE');
    if ~isempty(env_value)
        IDX_CANDIDATE = str2double(env_value);
    end
end


% Check and handle RES_PATH
if isempty(RES_PATH)
    RES_PATH = fullfile(ROOT, 'results');
elseif strcmp(env_sys, 'cluster') && strcmp(RES_PATH, 'env_var')
    RES_PATH = getenv(RESULTS);
elseif ~isAbsolutePath(RES_PATH)
    RES_PATH = fullfile(ROOT, RES_PATH);
end

% Check and handle INPUT_PATH
if isempty(INPUT_PATH)
    INPUT_PATH = fullfile(ROOT, 'inputs');
elseif strcmp(env_sys, 'cluster') && strcmp(INPUT_PATH, 'env_var')
    INPUT_PATH = getenv('INPUT_DIRECTORY'); 
elseif ~isAbsolutePath(INPUT_PATH)
    INPUT_PATH = fullfile(ROOT, INPUT_PATH);
end


% Display all settings and switches
disp('--- Settings and Switches ---');
disp(['SIM (Simulate Behavior): ', num2str(SIM)]);
disp(['FIT (Fit Behavior Data): ', num2str(FIT)]);
disp(['PLOT (Plot Results): ', num2str(PLOT)]);
disp(['EG_SUBJECT (Example Subject): ', num2str(EG_SUBJECT)]);
disp(['FIT_SUBJECT (Subject Identifier): ', FIT_SUBJECT]);
disp(['ROOT Path: ', ROOT]);
disp(['RES_PATH (Results Path): ', RES_PATH]);
disp(['INPUT_PATH (Input Path): ', INPUT_PATH]);
disp(['Environment System: ', env_sys]);
disp(['IDX_CANDIDATE: ', num2str(IDX_CANDIDATE)]);
disp('-----------------------------');

% 
% % Setup directories based on system
% if env_sys == "pc"
%     % ROOT = 'L:';
%     % results_dir = 'L:/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_fits_sandbox'; % Where the fit results will save
%     % INPUT_DIRECTORY = [root '/NPC/DataSink/StimTool_Online/WB_Advice'];  % Where the subject file is located
% 
% elseif env_sys == "mac"
%     [root, ~, ~] = fileparts(mfilename('fullpath'));
% 
%     % only run one subjuect, feng_self data
%     FIT_SUBJECT = 'FENGTEST';
%     results_dir = fullfile(root, 'results');
%     INPUT_DIRECTORY = fullfile(root, 'inputs');
% 
% 
% else
%     root = '/media/labs';
%     FIT_SUBJECT = getenv('SUBJECT');
%     results_dir = getenv('RESULTS');
%     INPUT_DIRECTORY = getenv('INPUT_DIRECTORY');
% 
% end
% 
% 
% fprintf([INPUT_DIRECTORY '\n']);
% fprintf([FIT_SUBJECT '\n']);


% Add external paths depending on the system
if strcmp(env_sys, 'pc')
    spmPath = 'L:/rsmith/all-studies/util/spm12/';
    spmDemPath = 'L:/rsmith/all-studies/util/spm12/toolbox/DEM/';
    tutorialPath = 'L:/rsmith/lab-members/cgoldman/Active-Inference-Tutorial-Scripts-main';
   
elseif strcmp(env_sys, 'mac')
    spmPath =  [ROOT '/spm/'];
    spmDemPath = [ROOT '/spm/toolbox/DEM/'];
    tutorialPath = [ROOT '/Active-Inference-Tutorial-Scripts-main'];

elseif strcmp(env_sys, 'cluster')
    spmPath = '/mnt/dell_storage/labs/rsmith/all-studies/util/spm12';
    spmDemPath = '/mnt/dell_storage/labs/rsmith/all-studies/util/spm12/toolbox/DEM';
    tutorialPath = '/mnt/dell_storage/labs/rsmith/lab-members/cgoldman/Active-Inference-Tutorial-Scripts-main';
   

end

addpath(spmPath);
addpath(spmDemPath);
addpath(tutorialPath);





% % for lab cluster, uncomment if needed
% if is_feng_local
%     addpath([root '/spm/']);
%     addpath([root '/spm/toolbox/DEM/']);
%     addpath([root '/Active-Inference-Tutorial-Scripts-main']);
% else
%     addpath([root '/rsmith/all-studies/util/spm12/']);
%     addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);
%     addpath([root '/rsmith/lab-members/cgoldman/Active-Inference-Tutorial-Scripts-main']);
% 
% end


% Define all parameters passed into the model; specify which ones to fit in
% field

all_params = struct(...
    'p_a', 0.8, ...
    'inv_temp', 4, ...
    'reward_value', 4, ...
    'l_loss_value', 4, ...
    'omega', 0.2, ...
    'omega_d_win', 0.2, ...
    'omega_d_loss', 0.2, ...
    'omega_a_win', 0.2, ...
    'omega_a_loss', 0.2, ...
    'omega_d', 0.2, ...
    'omega_a', 0.2, ...
    'eta', 0.5, ...
    'eta_d', 0.5, ...
    'eta_d_win', 0.5, ...
    'eta_d_loss', 0.5, ...
    'eta_a', 0.5, ...
    'eta_a_win', 0.5, ...
    'eta_a_loss', 0.5, ...
    'state_exploration', 1, ...
    'parameter_exploration', 0 ...
);


% 
% params.p_a = .8;
% params.inv_temp = 4;
% params.reward_value = 4;
% params.l_loss_value = 4;
% params.omega = .2;
% %params.omega_d_win = .2;
% %params.omega_d_loss = .2;
% %params.omega_a_win = .2;
% %params.omega_a_loss = .2;
% %params.omega_d = .2;
% %params.omega_a = .2;
% params.eta = 1;
% %params.eta_d = .5;
% %params.eta_d_win = .5;
% %params.eta_d_loss = .5;
% %params.eta_a = .5;
% %params.eta_a_win = .5;
% %params.eta_a_loss = .5;
% params.state_exploration = 1;
% params.parameter_exploration = 0;


% Define an array of 10 field combinations (cell arrays)
all_fields = {
    {'p_a', 'inv_temp', 'reward_value', 'l_loss_value'}, ...
    {'p_a', 'inv_temp', 'omega', 'reward_value', 'l_loss_value'}, ...
    {'p_a', 'inv_temp', 'omega', 'reward_value', 'l_loss_value', 'eta'}, ...
    {'p_a', 'inv_temp', 'omega', 'reward_value', 'l_loss_value', 'eta_d', 'eta_a'}, ...
    {'p_a', 'inv_temp', 'omega', 'reward_value', 'l_loss_value', 'eta_d_win', 'eta_d_loss', 'eta_a'}, ...
    {'p_a', 'inv_temp', 'omega', 'reward_value', 'l_loss_value', 'eta_d', 'eta_a_win', 'eta_a_loss'}, ...
    {'p_a', 'inv_temp', 'omega_d_win', 'omega_d_loss', 'omega_a_win', 'omega_a_loss', 'reward_value', 'l_loss_value'}, ...
    {'p_a', 'inv_temp', 'omega_d_win', 'omega_d_loss', 'omega_a', 'reward_value', 'l_loss_value'}, ...
    {'p_a', 'inv_temp', 'omega_d', 'omega_a_win', 'omega_a_loss', 'reward_value', 'l_loss_value'}, ...
    {'p_a', 'inv_temp', 'omega_d_win', 'omega_d_loss', 'omega_a_win', 'omega_a_loss', 'reward_value', 'l_loss_value', 'eta'}
};

all_fixeds = {
    {'omega', 0, 'eta', 1, 'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'eta', 1, 'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'eta', 1, 'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'eta', 1, 'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'eta', 1, 'state_exploration', 1, 'parameter_exploration', 0}, ...
    {'state_exploration', 1, 'parameter_exploration', 0}
};


field_params = all_fields{IDX_CANDIDATE}; % Retrieve the field for the given candidate
fixed_params = all_fixeds{IDX_CANDIDATE}; % Retrieve the fixed parameters for the given candidate
params = struct();
fields = field_params;
for i = 1:length(field_params)
    params.(field_params{i}) =  all_params.(field_params{i});
end
for i = 1:2:length(fixed_params)
    params.(fixed_params{i}) = fixed_params{i+1};
end




% Check conditions and perform actions based on FIT and SIM settings
if FIT && ~SIM
    % If only fitting is required
    disp('Performing fitting only...');
    % Add your fitting code here
    % Example: fit_model(candidate_params);

elseif FIT && SIM
    if strcmp(env_sys,'mac')|| strcmp(env_sys, 'cluster')
        [fit_results, DCM] = Advice_fit_prolific(FIT_SUBJECT, INPUT_PATH, params, fields, PLOT);
    else
        [fit_results, DCM] = Advice_fit(FIT_SUBJECT, INPUT_PATH, params, fields, PLOT);
    end
    
    fit_fields = fieldnames(fit_results);

    for i = 1:length(fit_fields)
        field_name = fit_fields{i};  
        if startsWith(field_name, 'posterior_')
            param_name = strrep(field_name, 'posterior_', '');
            if isfield(params, param_name)
                params.(param_name) = fit_results.(field_name);
            else
                warning('Field "%s" not found in params struct.', param_name);
            end
        end
    end

    sim_data = advise_sim(params, false, true);


    sim_fit_result = advise_sim_fit(sim_data, fields, params);


    detail_res_file_name = 'advice_task_model_identification'; % Base name for the model
    candidate_idx = num2str(IDX_CANDIDATE); % Convert candidate index to string
    file_name = [detail_res_file_name,'_',FIT_SUBJECT, '_', candidate_idx, '.csv']; % Create file name
    file_path = fullfile(RES_PATH, file_name); % Full path for the CSV file

    % Extract data from sim_fit_result for writing into CSV
    res_field_names = fieldnames(sim_fit_result); % Assuming each field corresponds to a subject

    if ~isfile(file_path)
        fid = fopen(file_path, 'w'); 
        if fid == -1
            error('Failed to open file: %s. Please check the file path and permissions.', file_path);
        end
        fprintf(fid, 'FIT_SUBJECT');
        field_names = fieldnames(sim_fit_result);
        for i = 1:length(field_names)
            fprintf(fid, ',%s', field_names{i});
        end
        fprintf(fid, '\n');
        fclose(fid);
    end
    fid = fopen(file_path, 'a'); 
    fprintf(fid, '%s', FIT_SUBJECT); 
    for i = 1:length(res_field_names)
        fprintf(fid, ',%f', sim_fit_result.(res_field_names{i}));
    end
    fprintf(fid, '\n'); % End the line for this subject
    fclose(fid);

 






elseif ~FIT && SIM
    % If only simulation is required
    disp('Performing simulation only...');
    % Add your simulation code here
    % Example: simulate_model(candidate_params);
else
    % If neither fitting nor simulation is enabled
    disp('No fitting or simulation to perform.');
end

% 
% if FIT
%         if ~local
%             [fit_results, DCM] = Advice_fit_prolific(FIT_SUBJECT, INPUT_DIRECTORY, params, field, plot);
%         else
%             [fit_results, DCM] = Advice_fit(FIT_SUBJECT, INPUT_DIRECTORY, params, field, plot);
%         end
% 
%         % feed the fitted parameters into advise_sim
% 
% 
%         %Loop through each field name and print the value
% 
%         fit_fields = fieldnames(fit_results);
% 
%         for i = 1:length(fit_fields)
%             field_name = fit_fields{i};  
%             if startsWith(field_name, 'posterior_')
%                 param_name = strrep(field_name, 'posterior_', '');
%                 if isfield(params, param_name)
%                     params.(param_name) = fit_results.(field_name);
%                 else
%                     warning('Field "%s" not found in params struct.', param_name);
%                 end
%             end
%         end
% 
%         sim_data = advise_sim(params, false, true);
% 
%         % fit the simulated behavior using advise_sim_fit
% 
%         sim_fit_result = advise_sim_fit(sim_data, field, params);
% 
% 
%         model_free_results = advise_mf(fit_results.file);
% 
% 
%         mf_fields = fieldnames(model_free_results);
%         for i=1:length(mf_fields)
%             fit_results.(mf_fields{i}) = model_free_results.(mf_fields{i});      
%         end
% 
%         writetable(struct2table(fit_results), [results_dir '/advise_task-' FIT_SUBJECT '_fits.csv']);
% end
% 
% 
% %end
% 
% 
% 
% 
% saveas(gcf,[results_dir '/' FIT_SUBJECT '_fit_plot.png']);
% save(fullfile([results_dir '/fit_results_' FIT_SUBJECT '.mat']), 'DCM');
% 

% Define the isAbsolutePath function
function isAbs = isAbsolutePath(givenPath)
    if ispc
        isAbs = length(givenPath) >= 2 && givenPath(2) == ':';
    elseif isunix || ismac
        isAbs = strncmp(givenPath, '/', 1);
    else
        error('Unknown operating system.');
    end
end

