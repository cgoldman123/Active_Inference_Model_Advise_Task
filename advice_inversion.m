% Samuel Taylor and Ryan Smith, 2021
% Model inversion script
function [DCM] = advice_inversion(DCM)

% MDP inversion using Variational Bayes
% FORMAT [DCM] = spm_dcm_mdp(DCM)

% If simulating - comment out section on line 196
% If not simulating - specify subject data file in this section 

%
% Expects:
%--------------------------------------------------------------------------
% DCM.MDP   % MDP structure specifying a generative model
% DCM.field % parameter (field) names to optimise
% DCM.U     % cell array of outcomes (stimuli)
% DCM.Y     % cell array of responses (action)
%
% Returns:
%--------------------------------------------------------------------------
% DCM.M     % generative model (DCM)
% DCM.Ep    % Conditional means (structure)
% DCM.Cp    % Conditional covariances
% DCM.F     % (negative) Free-energy bound on log evidence
% 
% This routine inverts (cell arrays of) trials specified in terms of the
% stimuli or outcomes and subsequent choices or responses. It first
% computes the prior expectations (and covariances) of the free parameters
% specified by DCM.field. These parameters are log scaling parameters that
% are applied to the fields of DCM.MDP. 
%
% If there is no learning implicit in multi-trial games, only unique trials
% (as specified by the stimuli), are used to generate (subjective)
% posteriors over choice or action. Otherwise, all trials are used in the
% order specified. The ensuing posterior probabilities over choices are
% used with the specified choices or actions to evaluate their log
% probability. This is used to optimise the MDP (hyper) parameters in
% DCM.field using variational Laplace (with numerical evaluation of the
% curvature).
%
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_dcm_mdp.m 7120 2017-06-20 11:30:30Z spm $

% OPTIONS
%--------------------------------------------------------------------------
ALL = false;

% prior expectations and covariance
%--------------------------------------------------------------------------
prior_variance = .5;

for i = 1:length(DCM.field)
    field = DCM.field{i};
    try
        % changed this from param = DCM.MDP.(field);
        param = DCM.priors.(field);
        param = double(~~param);
    catch
        param = 1;
    end
    if ALL
        pE.(field) = zeros(size(param));
        pC{i,i}    = diag(param);
    else
        if strcmp(field,'alpha')
            %pE.(field) = log(DCM.priors.(field)/(30-DCM.priors.(field)) - (.5/ (30 - .5)));    % bound between .5 and 30
            pE.(field) = log(DCM.priors.(field));              % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'beta')
            pE.(field) = log(1);                                % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'rs')
            pE.(field) = log(DCM.priors.(field));              % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'la')
            pE.(field) = log(DCM.priors.(field)/(4-DCM.priors.(field)));  % bound between 0 and 4
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'prior_a')
            %pE.(field) = log(DCM.priors.(field)/(30-DCM.priors.(field)) - (.25/ (30 - .25)));    % bound between .25 and 30
            pE.(field) = log(DCM.priors.(field));              % in log-space (to keep positive)
            %pC{i,i}    = prior_variance;
            pC{i,i}    = prior_variance; % making it easier to move prior_a in parameter space
        elseif strcmp(field,'prior_d')
            pE.(field) = log(1);                                % in log-space (to keep positive)
            pC{i,i}    = prior_variance;
         elseif strcmp(field,'eff')
             pE.(field) = log(DCM.priors.(field));              % in log-space (to keep positive)
             pC{i,i}    = prior_variance;
        elseif strcmp(field,'p_ha')
           % pE.(field) = log(DCM.priors.(field)/(.99-DCM.priors.(field)) - (.01/ (.99 - .01)));   
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'eta')
           % pE.(field) = log(DCM.priors.(field)/(.99-DCM.priors.(field)) - (.01/ (.99 - .01)));   
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
         elseif strcmp(field,'eta_win')
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
         elseif strcmp(field,'eta_loss')
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
         elseif strcmp(field,'novelty_scalar')
             pE.(field) = log(DCM.priors.(field));              % in log-space (to keep positive)
             pC{i,i}    = prior_variance;
        elseif strcmp(field,'omega')
            %pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)) - (.1 / (1 - .1)));      % bound between .1 and 1
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;     
        elseif strcmp(field,'omega_eta_advisor_win')
            %pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)) - (.1 / (1 - .1)));      % bound between .1 and 1
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
        elseif strcmp(field,'omega_eta_advisor_loss')
            %pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)) - (.1 / (1 - .1)));      % bound between .1 and 1
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
         elseif strcmp(field,'omega_eta_context')
            %pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)) - (.1 / (1 - .1)));      % bound between .1 and 1
            pE.(field) = log(DCM.priors.(field)/(1-DCM.priors.(field)));  % bound between 0 and 1
            pC{i,i}    = prior_variance;
        end
    end
end

pC      = spm_cat(pC);

% model specification
%--------------------------------------------------------------------------
M.L     = @(P,M,U,Y)spm_mdp_L(P,M,U,Y);  % log-likelihood function
M.pE    = pE;                            % prior means (parameters)
M.pC    = pC;                            % prior variance (parameters)
%M.mdp   = DCM.MDP;                       % MDP structure
M.mode  = DCM.mode;
M.trialinfo = DCM.trialinfo;

% Variational Laplace
%--------------------------------------------------------------------------
[Ep,Cp,F] = spm_nlsi_Newton(M,DCM.U,DCM.Y);

% Store posterior densities and log evidence (free energy)
%--------------------------------------------------------------------------
DCM.M   = M;
DCM.Ep  = Ep;
DCM.Cp  = Cp;
DCM.F   = F;


return

function L = spm_mdp_L(P,M,U,Y)
% log-likelihood function
% FORMAT L = spm_mdp_L(P,M,U,Y)
% P    - parameter structure
% M    - generative model
% U    - inputs
% Y    - observed repsonses
%__________________________________________________________________________

if ~isstruct(P); P = spm_unvec(P,M.pE); end

% multiply parameters in MDP
%--------------------------------------------------------------------------
%mdp   = M.mdp;
field = fieldnames(M.pE);
for i = 1:length(field)
    %for j = 1:length(vertcat(mdp.(field{i})))
        if strcmp(field{i},'p_ha')
            %params.(field{i}) = .99*(exp(P.(field{i})) + (.01/(.99 - .01))) / (exp(P.(field{i})) + (.01/(.99-.01) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
        elseif strcmp(field{i},'omega')
            %params.(field{i}) = (exp(P.(field{i})) + (.1 / (1 - .1))) / (exp(P.(field{i})) + (.1/(1-.1) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
            
         elseif strcmp(field{i},'omega_eta_advisor_loss')
            %params.(field{i}) = (exp(P.(field{i})) + (.1 / (1 - .1))) / (exp(P.(field{i})) + (.1/(1-.1) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
            
        elseif strcmp(field{i},'omega_eta_advisor_win')
            %params.(field{i}) = (exp(P.(field{i})) + (.1 / (1 - .1))) / (exp(P.(field{i})) + (.1/(1-.1) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
            
        elseif strcmp(field{i},'omega_eta_context')
            %params.(field{i}) = (exp(P.(field{i})) + (.1 / (1 - .1))) / (exp(P.(field{i})) + (.1/(1-.1) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
        elseif strcmp(field{i},'eta')
            %params.(field{i}) = (exp(P.(field{i})) + (.1 / (1 - .1))) / (exp(P.(field{i})) + (.1/(1-.1) + 1));
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
        elseif strcmp(field{i},'eta_win')
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
        elseif strcmp(field{i},'eta_loss')
            params.(field{i}) = 1/(1+exp(-P.(field{i})));
        elseif strcmp(field{i},'alpha')
            %params.(field{i}) = 30*(exp(P.(field{i})) + (.5/(30 - .5))) / (exp(P.(field{i})) + (.5/(30-.5) + 1));
            params.(field{i}) = exp(P.(field{i}));
        elseif strcmp(field{i},'la')
            params.(field{i}) = 4*exp(P.(field{i})) / (exp(P.(field{i}))+1);
            
        elseif strcmp(field{i},'rs')
            params.(field{i}) = exp(P.(field{i}));
        elseif strcmp(field{i},'prior_a')
            %params.(field{i}) = 30*(exp(P.(field{i})) + (.25/(30 - .25))) / (exp(P.(field{i})) + (.25/(30-.25) + 1));
            params.(field{i}) = exp(P.(field{i}));
        elseif strcmp(field{i},'novelty_scalar')
            params.(field{i}) = exp(P.(field{i}));
        end
    %end
end




% discern whether learning is enabled - and identify unique trials if not
%--------------------------------------------------------------------------
if any(ismember(fieldnames(params),{'a','b','d','c','d','e'}))
    j = 1:numel(U);
    k = 1:numel(U);
else
    % find unique trials (up until the last outcome)
    %----------------------------------------------------------------------
    u       = spm_cat(U');
    [i,j,k] = unique(u(:,1:(end - 1)),'rows');
end

num_trials = size(U,2);
num_blocks = floor(num_trials/30);
if num_trials == 1
    block_size = 1;
else
    block_size = 30;
end

trialinfo = M.trialinfo;
L = 0;

% Each block is separate -- effectively resetting beliefs at the start of
% each block. 
for idx_block = 1:num_blocks
    priors = params;
    MDP     = advise_gen_model(trialinfo(30*idx_block-29:30*idx_block,:),priors);
    %[MDP(1:block_size)]   = deal(mdp_block);
    if (num_trials == 1)
        outcomes = U;
        actions = Y;
        MDP.o  = outcomes{1};
        MDP.u  = actions{1};
    else
        outcomes = U(30*idx_block-29:30*idx_block);
        actions  = Y(30*idx_block-29:30*idx_block);
        for idx_trial = 1:30
            MDP(idx_trial).o = outcomes{idx_trial};
            MDP(idx_trial).u = actions{idx_trial};
        end
    end
    
    % solve MDP and accumulate log-likelihood
    %--------------------------------------------------------------------------
    
    %MDP  = spm_MDP_VB_X_advice(MDP);
    MDP  = spm_MDP_VB_X_advice_no_message_passing_faster(MDP);

    for j = 1:block_size
        if actions{j}(2,1) ~= 2
            L = L + log(MDP(j).P(1,actions{j}(2,1),1) + eps);
            
        else % when advisor was chosen
            prob_choose_advisor = MDP(j).P(1,actions{j}(2,1),1);
            L = L + log(prob_choose_advisor + eps);
            prob_choose_bandit = MDP(j).P(1,actions{j}(2,2),2);
            L = L + log(prob_choose_bandit + eps);
        end
    end

    clear('MDP')


end

fprintf('LL: %f \n',L)


