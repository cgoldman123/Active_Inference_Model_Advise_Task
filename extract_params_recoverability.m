% This function extracts the generative and estimated parameters from each subject fit (sim fitting),
% and writes them to one csv with all the gen params and one csv with all
% estimated

function extract_params()
directory = dir('L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\recoverability\fit_output\recoverability_output_advisor_omegas_rowwise');
index_array = find(arrayfun(@(n) contains(directory(n).name, 'recoverability_'),1:numel(directory)));
for index = index_array
    file = [directory(index).folder '\' directory(index).name];
    subdat{index} = readtable(file);
end
% Identify valid entries in subdat
valid_indices = find(cellfun(@(x) ~isempty(x) && height(x) == 2, subdat));

nValidEntries = numel(valid_indices);
first_valid_table = subdat{valid_indices(1)};
nParams = width(first_valid_table);

% Extract column names
colnames = first_valid_table.Properties.VariableNames;

% Initialize matrices
gen_params = NaN(nValidEntries, nParams);
estimated_params = NaN(nValidEntries, nParams);

for i = 1:nValidEntries
    idx = valid_indices(i);
    
    % Store generative parameters
    gen_params(i, :) = table2array(subdat{idx}(1, :));
    
    % Store estimated parameters
    estimated_params(i, :) = table2array(subdat{idx}(2, :));
end

gen_table = array2table(gen_params, 'VariableNames', colnames);
estimated_table = array2table(estimated_params, 'VariableNames', colnames);

writetable(gen_table, ['L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\recoverability\correlations_recoverability\' 'gen_params_advisor_omegas_rowwise.csv'], 'WriteRowNames',true);
writetable(estimated_table, ['L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\recoverability\correlations_recoverability\' 'estimated_params_advisor_omegas_rowwise.csv'], 'WriteRowNames',true);


% 
% % Calculate correlations column-wise
% correlations = zeros(1, nParams);
% for j = 1:nParams
%     correlations(j) = corr(gen_params(:, j), estimated_params(:, j), 'Rows', 'complete');
% end
% 
% % Pairing correlations with their respective column names
% correlation_table = array2table(correlations', 'VariableNames', {'Correlation'}, 'RowNames', colnames);
% 
% writetable(correlation_table, ['L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\scripts\recoverability_output_concentration_fix' 'corr_table.csv'], 'WriteRowNames',true);
% 
% 
% 
% % Get figure
% figure;
% for idx = 1:nParams
%     param = colnames{idx};
%     subplot(4,2,idx);
%     scatter(gen_params(:, idx), estimated_params(:, idx), 'filled');
%     lsline;
%     title(['Recoverability: ' param]);
%     xlabel(['True (Generative) ' param]);
%     ylabel(['Estimated ' param]);
% end
% 
% figureName = fullfile('L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\scripts\recoverability_output_concentration_fix', 'param_plot.png');
% saveas(gcf, figureName, 'png');

