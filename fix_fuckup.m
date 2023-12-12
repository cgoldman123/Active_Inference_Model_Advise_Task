% This is a function to fix a mistake I made with retransforming parameters
% after a fit
% The function reads in the untransformed results from the DCM .mat file, transforms them
% correctly, then puts them back into the results csv they should have been
% in to begin with

function parse_fit_results()
directory = dir('L:\rsmith\lab-members\cgoldman\Wellbeing\advise_task\scripts\recoverability_output_bounded');
index_array = find(arrayfun(@(n) contains(directory(n).name, 'fit_results'),1:numel(directory)));


for index = index_array
    file = [directory(index).folder '\' directory(index).name];
    load(file);
    
    pattern = 'fit_results_(.*).mat';
    out = regexp(file, pattern, 'tokens');
    num = out{1}{1};
    old_csv_file = [directory(index).folder '\recoverability_' num '.csv'];
    csv = readtable(old_csv_file);
    
    new_fit = struct2table(fit_results{1,4}.Ep);
    
 
    new_fit.p_ha = .99*(exp(new_fit.p_ha) + (.01/(.99 - .01))) / (exp(new_fit.p_ha) + (.01/(.99-.01) + 1));
    new_fit.omega = (exp(new_fit.omega) + (.1 / (1 - .1))) / (exp(new_fit.omega) + (.1/(1-.1) + 1));
    new_fit.alpha = 30*(exp(new_fit.alpha) + (.5/(30 - .5))) / (exp(new_fit.alpha) + (.5/(30-.5) + 1));
    new_fit.la = 4*exp(new_fit.la) / (exp(new_fit.la)+1);
    new_fit.prior_a = 30*(exp(new_fit.prior_a) + (.25/(30 - .25))) / (exp(new_fit.prior_a) + (.25/(30-.25) + 1));

    
    
    
    combined_csv = [csv; new_fit];
    writetable(combined_csv, old_csv_file);
end



