dbstop if error
rng('default');


SIM = false; % Generate simulated behavior (if false and FIT == true, will fit to subject file data instead)
FIT = true; % Fit example subject data 'BBBBB' or fit simulated behavior (if SIM == true)

% Setup directories based on system
if ispc
    root = 'L:';
    results_dir = 'L:/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_fits';
    FIT_SUBJECT = 'AD123';
    INPUT_DIRECTORY = [root '/rsmith/wellbeing/tasks/AdviceTask/behavioral_files_12-8-23'];  % Where the subject file is located

else
    root = '/media/labs';
    FIT_SUBJECT = getenv('SUBJECT');
    results_dir = getenv('RESULTS');
    INPUT_DIRECTORY = getenv('INPUT_DIRECTORY');

end


fprintf(INPUT_DIRECTORY);
fprintf(FIT_SUBJECT);



addpath([root '/rsmith/all-studies/util/spm12/']);
addpath([root '/rsmith/all-studies/util/spm12/toolbox/DEM/']);

% Define priors and parameter sequences
priors = struct('p_ha', 0.75, 'omega_advisor_win', 0.9, 'omega_advisor_loss', .9, 'omega_context', .9);
field = fieldnames(priors);


if SIM
    %alpha = 7; % bound between .5 and 30
    %rs = 4;
    p_ha = .9;
    %p_ha = 0.8368249 ; % bound between .01 and .99
   % prior_a = 4;
    %prior_a =  4.739768; % sim between 3 and __
    %omega = 0.5;
    %omega = 0.6844748 ; % .1 to 1
    %'eff', [1]; 
    %rs = 3.5; % 0 to 4
    omega_advisor_win = .9;
    omega_advisor_loss = .9;
    %omega_context = .9;
    %prior_a = 4;
    gen_params = struct('p_ha', p_ha, 'omega_advisor_win', omega_advisor_win, 'omega_advisor_loss', omega_advisor_loss);
    
    [gen_data] = advise_sim(gen_params);
end
    
if FIT
    if SIM
        fit_results = advise_sim_fit(gen_data, field, priors);
    else
    
        fit_results = Advice_fit(FIT_SUBJECT, INPUT_DIRECTORY, priors, field);

        % saves the matlab results
        % save([results_dir 'output_invitation_' subject '.mat'], 'fit_results');
        %field = {'p_ha' 'prior_a' 'omega' 'rs' 'alpha' 'la' 'eff'};
        res.subject = FIT_SUBJECT;
        res.num_blocks = size(fit_results{7},1)/30;
        res.p_ha = fit_results{3}.p_ha;
        res.omega_advisor_win = fit_results{3}.omega_advisor_win;
        res.omega_advisor_loss = fit_results{3}.omega_advisor_loss;
        %res.prior_a = fit_results{3}.prior_a;
        %res.omega_advisor_win = fit_results{3}.omega;
        %res.rs = fit_results{3}.rs;
        %res.alpha = fit_results{3}.alpha;
        %res.la = fit_results{3}.la;
        %res.eff = fit_results{3}(7);
        res.avg_act = fit_results{5};
        res.model_acc = fit_results{6};
        
        writetable(struct2table(res), [results_dir '/advise_task-' FIT_SUBJECT '_fits.csv']);
    end

    
end

    
    


save(fullfile([results_dir '/fit_results_' FIT_SUBJECT '.mat']), 'fit_results');
                            
