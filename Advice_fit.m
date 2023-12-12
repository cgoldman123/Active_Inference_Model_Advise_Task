function FinalResults = Advice_fit(subject,folder,priors,field)
% Manipulate Data
directory = dir(folder);
index_array = find(arrayfun(@(n) contains(directory(n).name, [subject '-T0-__AT_R1-_BEH.csv']),1:numel(directory)));
file = [folder '/' directory(index_array).name];

subdat = readtable(file);
subdat = subdat(max(find(ismember(subdat.trial_type,'MAIN')))+1:end,:);

% probdat = string(subdat(subdat.event_code==10,:).trial_type);
% probdat = strrep(probdat,'_',' ');
% for i = 1:length(probdat)
%     tri = convertStringsToChars(strsplit(probdat(i)));
%     adv{i} = tri{3};
%     lb{i} = tri{1};
%     sz{i} = tri{4};
% end
% trialinfo = horzcat(adv',lb',sz');
load('trialinfo_forty_eighty.mat');
trialinfo = trialinfo_forty_eighty;

% lets look at options selected
left_right_chosen = subdat(subdat.event_code==8, :);
% if the person managed to cause a glitch and select two bandits in one 
% trial, use only the first one as response/result
[~, idx] = unique(left_right_chosen.trial_number, 'first');
left_right_chosen = left_right_chosen(idx, :);
resp = left_right_chosen.response;
points = left_right_chosen.result;
% re = tp(~ismember(tp.result, {'try right', 'try left'}),:).result;
% w_ad = tp(ismember(tp.result, {'try right', 'try left'}),{'trial' 'result'});

got_advice = subdat.event_code ==6;
trials_got_advice = subdat.trial_number(got_advice);
trials_got_advice = trials_got_advice + 1;
advice_given = subdat.response(got_advice);


for n = 1:size(resp,1)
    % indicate if participant chose right or left
    if ismember(resp(n),'right')
        r=4;
    elseif ismember(resp(n),'left')
        r=3;
     elseif ismember(resp(n),'none')
        error("this person chose the did nothing option and our scripts are not set up to allow that")
    end 
    
    if str2double(points{n}) >0 
        pt=3;
    elseif str2double(points{n}) <0 
        pt=2;
    else
        error("this person chose the did nothing option and our scripts are not set up to allow that")
    end

    if ismember(n, trials_got_advice)
        u{n} = [1 2; 1 r]';
        index = find(trials_got_advice == n);
        if strcmp(advice_given{index}, 'right')
            y = 3;
        elseif strcmp(advice_given{index}, 'left')
            y = 2;
        end
        o{n} = [1 y 1; 1 1 pt; 1 2 r];
    else
        u{n} = [1 r; 1 1]';
        o{n} = [1 1 1; 1 pt 1; 1 r 1];
    end

end

%     MDP = advise_gen_model(trialinfo,priors);

%     for bb = 1:size(MDP,2)
%         if mod(bb, 30) ~= 0
%             MDP(bb).BN = floor(bb/30)+1;        % block number
%         else
%             MDP(bb).BN = floor(bb/30);
%         end
%     end

%    DCM.MDP    = MDP;              % MDP model
    DCM.trialinfo = trialinfo;
    DCM.field  = field;            % Parameter field
    DCM.U      = o;              % trial specification (stimuli)
    DCM.Y      = u;              % responses (action)
    DCM.priors = priors;
    DCM.mode            = 'fit';

    DCM        = advice_inversion(DCM);   % Invert the model
 %% 6.3 Check deviation of prior and posterior means & posterior covariance:
    %==========================================================================

    %--------------------------------------------------------------------------
    % re-transform values and compare prior with posterior estimates
    %--------------------------------------------------------------------------
    field = fieldnames(DCM.M.pE);
     for i = 1:length(field)
    %for j = 1:length(vertcat(mdp.(field{i})))
        if strcmp(field{i},'p_ha')
%             posterior(i) = .99*(exp(DCM.Ep.(field{i})) + (.01/(.99 - .01))) / (exp(DCM.Ep.(field{i})) + (.01/(.99-.01) + 1));
%             prior(i) = .99*(exp(DCM.M.pE.(field{i})) + (.01/(.99 - .01))) / (exp(DCM.M.pE.(field{i})) + (.01/(.99-.01) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));
            
        elseif strcmp(field{i},'omega')
%             posterior(i) = (exp(DCM.Ep.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.Ep.(field{i})) + (.1/(1-.1) + 1));
%             prior(i) = (exp(DCM.M.pE.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.M.pE.(field{i})) + (.1/(1-.1) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));
        elseif strcmp(field{i},'omega_advisor_win')
%             posterior(i) = (exp(DCM.Ep.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.Ep.(field{i})) + (.1/(1-.1) + 1));
%             prior(i) = (exp(DCM.M.pE.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.M.pE.(field{i})) + (.1/(1-.1) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));
            
        elseif strcmp(field{i},'omega_advisor_loss')
%             posterior(i) = (exp(DCM.Ep.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.Ep.(field{i})) + (.1/(1-.1) + 1));
%             prior(i) = (exp(DCM.M.pE.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.M.pE.(field{i})) + (.1/(1-.1) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));
            
        elseif strcmp(field{i},'omega_context')
%             posterior(i) = (exp(DCM.Ep.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.Ep.(field{i})) + (.1/(1-.1) + 1));
%             prior(i) = (exp(DCM.M.pE.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.M.pE.(field{i})) + (.1/(1-.1) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));
        elseif strcmp(field{i},'eta')
%             posterior(i) = (exp(DCM.Ep.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.Ep.(field{i})) + (.1/(1-.1) + 1));
%             prior(i) = (exp(DCM.M.pE.(field{i})) + (.1 / (1 - .1))) / (exp(DCM.M.pE.(field{i})) + (.1/(1-.1) + 1));
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i})));  
        elseif strcmp(field{i},'eta_win')
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i}))); 
        elseif strcmp(field{i},'eta_loss')
            posteriors.(field{i}) = 1/(1+exp(-DCM.Ep.(field{i})));
            prior.(field{i}) = 1/(1+exp(-DCM.M.pE.(field{i}))); 
        elseif strcmp(field{i},'alpha')
%             posterior(i) = 30*(exp(DCM.Ep.(field{i})) + (.5/(30 - .5))) / (exp(DCM.Ep.(field{i})) + (.5/(30-.5) + 1));
%             prior(i) = 30*(exp(DCM.M.pE.(field{i})) + (.5/(30 - .5))) / (exp(DCM.M.pE.(field{i})) + (.5/(30-.5) + 1));
            posteriors.(field{i}) = exp(DCM.Ep.(field{i}));
            prior.(field{i}) = exp(DCM.M.pE.(field{i}));
        elseif strcmp(field{i},'la')
            posteriors.(field{i}) = 4*exp(DCM.Ep.(field{i})) / (exp(DCM.Ep.(field{i}))+1);
            prior.(field{i}) = 4*exp(DCM.M.pE.(field{i})) / (exp(DCM.M.pE.(field{i}))+1);
        elseif strcmp(field{i},'prior_a')
%             posterior(i) = 30*(exp(DCM.Ep.(field{i})) + (.25/(30 - .25))) / (exp(DCM.Ep.(field{i})) + (.25/(30-.25) + 1));
%             prior(i) = 30*(exp(DCM.M.pE.(field{i})) + (.25/(30 - .25))) / (exp(DCM.M.pE.(field{i})) + (.25/(30-.25) + 1));
            posteriors.(field{i}) = exp(DCM.Ep.(field{i}));
            prior.(field{i}) = exp(DCM.M.pE.(field{i}));
        elseif strcmp(field{i},'rs')
            posteriors.(field{i}) = exp(DCM.Ep.(field{i}));
            prior.(field{i}) = exp(DCM.M.pE.(field{i}));        
    
        end
    end
    
   
    

    % Simulate beliefs using fitted values to get avg action prob
    all_MDPs = [];

    % Simulate beliefs using fitted values
    act_prob=[];
    model_acc=[];
    
    u = DCM.U;
    y = DCM.Y;
    
   
    
    num_trials = size(u,2);
    num_blocks = floor(num_trials/30);
    if num_trials == 1
        block_size = 1;
    else
        block_size = 30;
    end

    trialinfo = DCM.M.trialinfo;


    % Each block is separate -- effectively resetting beliefs at the start of
    % each block. 
    for idx_block = 1:num_blocks
        priors = posteriors;
        
        MDP     = advise_gen_model(trialinfo(30*idx_block-29:30*idx_block,:),priors);

        if (num_trials == 1)
            outcomes = u;
            actions = y;
            MDP.o  = outcomes{1};
            MDP.u  = actions{1};
        else
            outcomes = u(30*idx_block-29:30*idx_block);
            actions  = y(30*idx_block-29:30*idx_block);
            for idx_trial = 1:30
                MDP(idx_trial).o = outcomes{idx_trial};
                MDP(idx_trial).u = actions{idx_trial};
            end
        end

        % solve MDP and accumulate log-likelihood
        %--------------------------------------------------------------------------

     %MDPs  = spm_MDP_VB_X_advice(MDP); 
     %MDPs  = spm_MDP_VB_X_advice_no_message_passing(MDP); 
     MDPs  = spm_MDP_VB_X_advice_no_message_passing_faster(MDP); 
     for j = 1:numel(actions)
        if actions{j}(2,1) ~= 2
           act_prob = [act_prob MDPs(j).P(1,actions{j}(2,1),1)];
           if MDPs(j).P(1,actions{j}(2,1),1)==max(MDPs(j).P(:,:,1))
               model_acc = [model_acc 1];
           else
               model_acc = [model_acc 0];
           end
        else % when advisor was chosen
           act_prob = [act_prob MDPs(j).P(1,actions{j}(2,1),1) MDPs(j).P(1,actions{j}(2,2),2)];
           for k = 1:2
               if MDPs(j).P(1,actions{j}(2,k),k)==max(MDPs(j).P(:,:,k))
                   model_acc = [model_acc 1];
               else
                   model_acc = [model_acc 0];
               end
           end
        end
     end
    % Save block of MDPs to list of all MDPs
     all_MDPs = [all_MDPs; MDPs'];

    clear MDPs

    end


    avg_act = sum(act_prob)/length(act_prob);
    p_acc   = sum(model_acc)/length(model_acc);
    
    
    
 
   
    FinalResults = [{["fitted " subject]} prior posteriors DCM avg_act p_acc all_MDPs];
end