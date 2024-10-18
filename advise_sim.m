%% Step by step introduction to building and using active inference models
function [gen_data] = advise_sim(priors, plot, not_MDP_format)

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
if nargin < 3  % nargin returns the number of input arguments passed to the function
    not_MDP_format = false;
end

if ~not_MDP_format

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
            % define MDP empty
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

else

    
    
    trialinfo = trialinfo_forty_eighty;
    
    all_MDPs = [];
    % loop all 12 blocks
    for idx_block = 1:12
        % loop all the trial
        for idx_trial = 1:30
            % locate the idx of trial in the traininfo, prob of right is better 
            task.true_p_right(idx_trial) = 1-str2double(trialinfo{(idx_block-1)*30+idx_trial,2});
            % truct prob
            task.true_p_a(idx_trial) = str2double(trialinfo{(idx_block-1)*30+idx_trial,1});
        end

        % after read the whole block, read the first trail data
        % 80 is big loss, 40 is small loss
        if strcmp(trialinfo{idx_block*30-29,3}, '80')
            task.block_type = "LL";
        else
            task.block_type = "SL";
        end
        % define MDP empty

        params = priors;

        MDPs  = Feng_Simple_Advice_Model_CMG(task,params);
        gen_data.trialinfo = trialinfo;
        for idx_trial = 1:30
            % 0 is no hint, 1 is left hint, 2 is right hint
            % for y, 2 left , 3 right
            y = MDPs.observations.hints(idx_trial)+1;

            % choices : 1 is advisor, 2 is left, 3 is right
            % for r, left 3, right 4
            if y == 1
                r = MDPs.choices(idx_trial, 1)+1;
            else
                r = MDPs.choices(idx_trial, 2)+1;
            end

            % 1 is win, 2 is loss
            % for pt, 3 win, 4 loss
            pt = -MDPs.observations.rewards(idx_trial)+4;

            if y==1
                u = [1,1;r,1];
                o = [1,1,1;1,pt,1;1,r,1];
            else
                u = [1,1;2,r];
                o = [1,y,1;1,1,pt;1,2,r];
                
            end

            idx_gen_data = (idx_block - 1) * 30 + idx_trial;  
            % store gen_data.observations
            gen_data.observations{idx_gen_data} = o;

            % store gen_data.responses 
            gen_data.responses{idx_gen_data} = u;
        end

    end 

   

     

end 

%clear MDP
clear MDP trialinfo room