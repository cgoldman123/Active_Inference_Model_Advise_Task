dbstop if error
rng('default');

% Setup directories based on system
if ispc
    root = 'L:';
    results_dir = 'L:/rsmith/lab-members/cgoldman/Wellbeing/recoverability/fit_output/recoverability_output';
else
    root = '/media/labs';
    results_dir = getenv('RESULTS');
    sim_ID = getenv('ID');
    sim_ID = num2str(sim_ID);
  %  gen_alpha = getenv('ALPHA');
  %  gen_alpha = str2double(gen_alpha);
  %  gen_rs = getenv('RS');
   % gen_rs = str2double(gen_rs);
    gen_p_ha = getenv('PHA');
    gen_p_ha = str2double(gen_p_ha);
%     gen_prior_a = getenv('PRIORA');
%     gen_prior_a = str2double(gen_prior_a);
%     gen_omega_context = getenv('OMEGA_CONTEXT');
%     gen_omega_context = str2double(gen_omega_context);
    gen_omega_advisor_win = getenv('OMEGA_ADVISOR_WIN');
    gen_omega_advisor_win = str2double(gen_omega_advisor_win);
    gen_omega_advisor_loss = getenv('OMEGA_ADVISOR_LOSS');
    gen_omega_advisor_loss = str2double(gen_omega_advisor_loss);
%     gen_eff = getenv('EFF');
%     gen_eff = str2double(gen_eff);
%     gen_la = getenv('LA');
%     gen_la = str2double(gen_la);
%     gen_eta = getenv('ETA');
%     gen_eta = str2double(gen_eta);
%     gen_eta_win = getenv('ETA_WIN');
%     gen_eta_win = str2double(gen_eta_win);
%     gen_eta_loss = getenv('ETA_LOSS');
%     gen_eta_loss = str2double(gen_eta_loss);
    
end

addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);

% Define priors and parameter sequences
priors = struct('p_ha', 0.75, 'omega_advisor_win', .8, 'omega_advisor_loss', .8);
priors

% Loop through all combinations of parameters

gen_params = struct('p_ha', gen_p_ha, 'omega_advisor_win', gen_omega_advisor_win, 'omega_advisor_loss', gen_omega_advisor_loss);
gen_params

[gen_data] = advise_sim(gen_params);
fit_results = advise_sim_fit(gen_data, fieldnames(priors), priors);

temp = fit_results(3);
res = temp{:,:};


save(fullfile([results_dir '/fit_results_' sim_ID '.mat']), 'fit_results');

gen_params.avg_action_prob = fit_results{5};
res.avg_action_prob = fit_results{5};
gen_params.model_acc = fit_results{6};
res.model_acc = fit_results{6};
gen_and_estimated = [gen_params, res];
combined_res = reshape(gen_and_estimated, [], 1);
writetable(struct2table(combined_res), [results_dir '/recoverability_' sim_ID '.csv']);