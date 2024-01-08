% This function extracts the generative and estimated parameters from each subject fit (sim fitting),
% and writes them to one csv with all the gen params and one csv with all
% estimated

function extract_params_fits()
directory = dir('L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\fitting_actual_data\advise_fits_alpha_and_novelty_scalar');
index_array = find(arrayfun(@(n) contains(directory(n).name, 'advise_task'),1:numel(directory)));
for index = index_array
    file = [directory(index).folder '\' directory(index).name];
    subdat{index} = readtable(file);
end
% Identify valid entries in subdat
valid_indices = find(cellfun(@(x) ~isempty(x) && height(x) == 1, subdat));
nValidEntries = numel(valid_indices);
first_valid_table = subdat{valid_indices(1)};
nParams = width(first_valid_table);

% Extract column names
colnames = first_valid_table.Properties.VariableNames;


for i = 1:nValidEntries
    idx = valid_indices(i);
    
    current_table = subdat{idx};
    % convert cells to strings
    for k = 1 : width(current_table)
    % Check if the current column is not a cell
        if ~isstring(current_table.(k))
            % Convert the column to a cell array
            current_table.(k) = string(current_table.(k));
        end
    end
    
    % Store estimated parameters
    estimated_params(i, :) = table2array(current_table(1, :));
end

estimated_table = array2table(estimated_params, 'VariableNames', colnames);

writetable(estimated_table, ['L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\fitting_actual_data\compiled_fit_results\' 'advise_fits_alpha_novelty_scalar.csv'], 'WriteRowNames',true);


