%% Step by step introduction to building and using active inference models
function [gen_data] = advise_sim(priors, plot)

% rng('shuffle') % This sets the random number generator to produce a different 
%                % random sequence each time, which leads to variability in 
%                % repeated simulation results (you can alse set to 'default'
%                % to produce the same random sequence each time)

% if (room == 60)
%     load('trialinfo_sixty.mat')
%     trialinfo = trialinfo_sixty;
% elseif (room == 100)
%     load('trialinfo_hundred.mat')
%     trialinfo = trialinfo_hundred;
% end           
load('trialinfo_forty_eighty.mat');
              
               
Sim = 0; % new model


if Sim==0 % new model
    trialinfo = trialinfo_forty_eighty;
    
    all_MDPs = [];
    for idx_block = 1:12
        for idx_trial = 1:30
            task.true_p_right(idx_trial) = 1-str2double(trialinfo{(idx_block-1)*30+idx_trial,2});
            task.true_p_a(idx_trial) = str2double(trialinfo{(idx_block-1)*30+idx_trial,1});
        end
        if strcmp(trialinfo{idx_block*30-29,3}, '80')
            task.block_type = "LL";
        else
            task.block_type = "SL";
        end
        MDP = [];
        params = priors;
        sim = 1;
        MDPs  = Simple_Advice_Model_CMG(task, MDP,params, sim);
        all_MDPs = [all_MDPs; MDPs'];
    end







elseif Sim ==1
    %% 3. Single trial simulations

    %--------------------------------------------------------------------------
    % Now that the generative process and model have been generated, we can
    % simulate a single trial using the spm_MDP_VB_X script. Here, we provide 
    % a version specific to this tutorial - spm_MDP_VB_X_tutorial_advice - that adds 
    % the learning rate (eta) for initial state priors (d), and adds forgetting rate (omega), 
    % which are not included in the current SPM version (as of 05/08/21).
    %--------------------------------------------------------------------------
    % trialinfo = {pHA, pLB, LA}

    mdp = advise_gen_model(trialinfo_forty_eighty(1,:), priors);

    %MDP = spm_MDP_VB_X_advice(mdp);
    %MDP = spm_MDP_VB_X_advice_no_message_passing(mdp);
    MDP = spm_MDP_VB_X_advice_no_message_passing_faster(mdp);

    % We can then use standard plotting routines to visualize simulated neural 
    % responses

     spm_figure('GetWin','Figure 1'); clf    % display behavior
     spm_MDP_VB_LFP(MDP); 
 
     %  and to show posterior beliefs and behavior:
 
     spm_figure('GetWin','Figure 2'); clf    % display behavior
     spm_MDP_VB_trial(MDP); 

    % Please see the main text for figure interpretations

elseif Sim == 4
    %% 4. Single block simulations
    % for games with 80 dinner size
    %mdp = advise_gen_model(trialinfo_forty_eighty(61:90,:), priors);
    %mdp = advise_gen_model(trialinfo_forty_eighty(181:210,:), priors);
    mdp = advise_gen_model(trialinfo_forty_eighty(1:30,:), priors);
    
    
    %MDP = spm_MDP_VB_X_advice(mdp);
    %MDP = spm_MDP_VB_X_advice_no_message_passing(mdp);
    MDP = spm_MDP_VB_X_advice_no_message_passing_faster(mdp);

    % We can again visualize simulated neural responses
    if plot
        spm_figure('GetWin','Figure 4'); clf    % display behavior
        spm_MDP_VB_game_tutorial(MDP); 
    end

    %mdp.la_true = la;   % Carries over true la value for use in estimation script
    %mdp.rs_true = rs;   % Carries over true rs value for use in estimation script

elseif Sim == 5
    % simulate all of the 60 or 100 blocks
    mdp = advise_gen_model(trialinfo_forty_eighty, priors);
    %MDP = spm_MDP_VB_X_advice(mdp);
    %MDP = spm_MDP_VB_X_advice_no_message_passing(mdp);
    MDP = spm_MDP_VB_X_advice_no_message_passing_faster(mdp);
    if plot
        advise_plot_cmg(MDP);
    end


end
gen_data = struct(                ...
    'observations', {MDP.o}',       ...
    'responses', {MDP.u}',           ...
    'trialinfo', {trialinfo_forty_eighty}'  ...
);

%clear MDP
clear MDP trialinfo room