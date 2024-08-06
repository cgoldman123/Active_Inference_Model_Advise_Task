% main script for fitting/simming behavior on the advise task
dbstop if error
rng('default');


SIM = false; % Generate simulated behavior (if false and FIT == true, will fit to subject file data instead)
FIT = true; % Fit example subject data 'BBBBB' or fit simulated behavior (if SIM == true)
plot = false;
%indicate if prolific or local
local = false;

% Setup directories based on system
if ispc
    root = 'L:';
    results_dir = 'L:/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_fits_sandbox';
    FIT_SUBJECT = '603c92ad5ed1c29cf04476ca';
    %INPUT_DIRECTORY = [root '/rsmith/wellbeing/tasks/AdviceTask/behavioral_files_2-6-24'];  % Where the subject file is located
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

% Define priors and parameter sequences
% priors = struct('p_ha', 0.75, 'omega_eta_advisor_win', 0.6, 'omega_eta_advisor_loss', .6, 'omega_eta_context', .6, 'novelty_scalar', .3, 'alpha', 2);
% field = fieldnames(priors);
priors = struct('p_a', 0.8, 'omega', 0.2, 'reward_value',4, ...
    'inv_temp', 4, 'eta_a_win', .5, 'eta_a_loss', .5, 'eta_d', .5,...
    'state_exploration', 4, 'parameter_exploration', 4, 'l_loss_value', 4);
field = fieldnames(priors);


if SIM
    p_ha = .75;
    omega_eta_context = 0.6;
    omega_eta_advisor_win = .6;
    omega_eta_advisor_loss = .6;
    novelty_scalar = .3;
    alpha = 2;
    
    gen_params = struct('alpha', alpha, 'novelty_scalar', novelty_scalar', 'omega_eta_context', omega_eta_context, ...
        'p_ha', p_ha, 'omega_eta_advisor_win', omega_eta_advisor_win, 'omega_eta_advisor_loss', omega_eta_advisor_loss);
    
    [gen_data] = advise_sim(gen_params, plot);
end
    
if FIT
    if SIM
        fit_results = advise_sim_fit(gen_data, field, priors);
    else
    
        if ~local
            fit_results = Advice_fit_prolific(FIT_SUBJECT, INPUT_DIRECTORY, priors, field, plot);
        else
            fit_results = Advice_fit(FIT_SUBJECT, INPUT_DIRECTORY, priors, field, plot);
        end
        
        model_free_results = advise_mf(fit_results{7});
        
        
        res.subject = FIT_SUBJECT;
        res.model_name = 'Corrected Combined Learning/Forgetting';
        res.num_blocks = size(fit_results{4}.U,2)/30;
        res.p_ha = fit_results{3}.p_ha;
        res.omega_eta_advisor_win = fit_results{3}.omega_eta_advisor_win;
        res.omega_eta_advisor_loss = fit_results{3}.omega_eta_advisor_loss;
        res.omega_eta_context = fit_results{3}.omega_eta_context;
        res.alpha = fit_results{3}.alpha;
        res.novelty_scalar = fit_results{3}.novelty_scalar;
        res.avg_act_prob_time1 = fit_results{5}.avg_act_prob_time1;
        res.avg_act_prob_time2 = fit_results{5}.avg_act_prob_time2;
        res.avg_model_acc_time1 = fit_results{5}.avg_model_acc_time1;
        res.avg_model_acc_time2 = fit_results{5}.avg_model_acc_time2;
        res.times_chosen_advisor = fit_results{5}.times_chosen_advisor;
        res.has_practice_effects = fit_results{6};
        
        mf_fields = fieldnames(model_free_results);
        for i=1:length(mf_fields)
            res.(mf_fields{i}) = model_free_results.(mf_fields{i});      
        end
        
        writetable(struct2table(res), [results_dir '/advise_task-' FIT_SUBJECT '_fits.csv']);
    end

    
end

    
    

saveas(gcf,[results_dir '/' FIT_SUBJECT '_fit_plot.png']);
save(fullfile([results_dir '/fit_results_' FIT_SUBJECT '.mat']), 'fit_results');
                            
