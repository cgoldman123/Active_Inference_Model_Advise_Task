% Script to verify that the observed advisor accuracy and left correct
% accuracy aligns with generative probabilities
function result_table = check_observed_matches_generative() 
subject_list_file = "L:/rsmith/lab-members/cgoldman/Wellbeing/advise_task/fitting_actual_data/advise_subject_IDs.csv";
subject_table = readtable(subject_list_file, 'ReadVariableNames', false);
subject_list = subject_table{2:end, 1}; 

folder = 'L:/rsmith/wellbeing/tasks/AdviceTask/behavioral_files_12-14-23';
result_table = table();

for i = 1:length(subject_list)
    subject = subject_list{i};
    directory = dir(folder);
    index_array = find(arrayfun(@(n) contains(directory(n).name, [subject '-T0-__AT_R1-_BEH.csv']),1:numel(directory)));
    file = [folder '/' directory(index_array).name];

    subdat = readtable(file);
    subdat = subdat(max(find(ismember(subdat.trial_type,'MAIN')))+1:end,:);
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
    
    got_advice = subdat.event_code ==6;
    trials_got_advice = subdat.trial_number(got_advice);
    trials_got_advice = trials_got_advice + 1;
    advice_given = subdat.response(got_advice);

    % skip participants who don't have complete data
    if size(resp,1) ~= 360
        continue;
    end
        
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
    
    % Now we have all of this subject's data
    % initialize counters for how many times the probability left was
    % better was .2
    left_better_point_two = 0;
    left_better_point_four = 0;
    left_better_point_six = 0;
    left_better_point_eight = 0;
    advisor_acc_reliable = 0;
    advisor_acc_unreliable = 0;
    
    total_left_point_two = 0;
    total_left_point_four = 0;
    total_left_point_six = 0;
    total_left_point_eight = 0;
    % how many times was the advisor chosen when it was reliable
    total_advisor_chosen_reliable = 0;
    % how many times was the advisor chosen when it was unreliable
    total_advisor_chosen_unreliable = 0;

    % let's get all of the times that left was correct when the probability
    % that left was correct was .2,.4,.6,.8
    for j = 1:size(o, 2)
        if trialinfo{j, 2} == '0.2'
            % If the value in the second column is 0.2, store the row number
            left_better_point_two = left_better_point_two+ was_left_better(j,o);
            total_left_point_two = total_left_point_two + 1;
        elseif trialinfo{j, 2} == '0.4'
            left_better_point_four = left_better_point_four + was_left_better(j,o);
            total_left_point_four = total_left_point_four + 1;
        elseif trialinfo{j, 2} == '0.6'
            left_better_point_six = left_better_point_six + was_left_better(j,o);
            total_left_point_six = total_left_point_six + 1;
        elseif trialinfo{j, 2} == '0.8'
            left_better_point_eight = left_better_point_eight + was_left_better(j,o);
            total_left_point_eight = total_left_point_eight + 1;
        end
        
        % let's look at how accurate advisor was
        % only look at trials where advisor was chosen
        if ismember(j,trials_got_advice)
            % advisor reliable trials
            if trialinfo{j, 1} == '0.9'
                % If the value in the first column is 0.9, store the row number
                advisor_acc_reliable = advisor_acc_reliable+ was_advisor_accurate(j,o);
                total_advisor_chosen_reliable = total_advisor_chosen_reliable + 1;
            % advisor unreliable trials
            elseif trialinfo{j, 1} == '0.5'
                advisor_acc_unreliable = advisor_acc_unreliable + was_advisor_accurate(j,o);
                total_advisor_chosen_unreliable = total_advisor_chosen_unreliable + 1;
            end
        end
    end
   

    % Calculate ratios
    ratio_point_two = left_better_point_two / total_left_point_two;
    ratio_point_four = left_better_point_four / total_left_point_four;
    ratio_point_six = left_better_point_six / total_left_point_six;
    ratio_point_eight = left_better_point_eight / total_left_point_eight;
    adv_accuracy_reliable = advisor_acc_reliable / total_advisor_chosen_reliable;
    adv_accuracy_unreliable = advisor_acc_unreliable / total_advisor_chosen_unreliable;

        
    
    newRow = table({subject}, ratio_point_two, ratio_point_four, ratio_point_six, ratio_point_eight, ...
                    adv_accuracy_reliable, adv_accuracy_unreliable, ...
                   'VariableNames', {'ParticipantID', 'Ratio0_2', 'Ratio0_4', 'Ratio0_6', 'Ratio0_8', ...
                   'adv_accuracy_reliable', 'adv_accuracy_unreliable'});
    result_table = [result_table; newRow];
        
end
    
    
    
end



% helper function returns true if choosing left resulted in win or choosing
% right resulted in loss
function result = was_left_better(trial_number, o)
    % Check if the advisor was chosen and look in the appropriate cell for win or loss
    trial_cell = o(trial_number);
    trial_cell = trial_cell{:};
    result = o(trial_number);
    if trial_cell(1,2) == 2 || trial_cell(1,2) == 3
        % return true if they got a win and chose the left option, false
        % otherwise
        result = double(~xor((result{:}(2,3) == 3),(result{:}(3,3) == 3)));
    else
        result = double(~xor((result{:}(2,2) == 3),(result{:}(3,2) == 3)));
    end
end


function result = was_advisor_accurate(trial_number, o)
    % Check if the advisor was chosen and look in the appropriate cell for win or loss
    trial_cell = o(trial_number);
    trial_cell = trial_cell{:};
    result = o(trial_number);
    % advisor says go left
    if trial_cell(1,2) == 2
        % return true if following left led to win or not following
        % advice led to not win
        result = double(~xor((result{:}(3,3) == 3),(result{:}(2,3) == 3)));
    % advisor says go right     
    else
        % return true if following right led to win or not following
        % advice led to not win
        result = double(~xor((result{:}(3,3) == 4),(result{:}(2,3) == 3)));
    end
        
 
end