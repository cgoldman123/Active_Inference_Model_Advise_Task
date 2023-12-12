% Clear workspace
clear all;

% Set the random number generator to default
rng('default');

% Define the number of values for each parameter (2 in this case)
num_values = 3;

% Generate evenly spaced parameter values
p_ha_values = linspace(0.01, 0.99, num_values);
prior_a_values = linspace(1, 10, num_values);
omega_values = linspace(0.01, 0.99, num_values);

% Create a meshgrid for the parameter values
[p_ha_mesh, prior_a_mesh, omega_mesh] = meshgrid(p_ha_values, prior_a_values, omega_values);

% Reshape the parameter values into column vectors
p_ha_values = p_ha_mesh(:);
prior_a_values = prior_a_mesh(:);
omega_values = omega_mesh(:);

% Create a figure
figure;

% Define the number of vertices
num_vertices = num_values^3;

% Define the edges of the cube
edges = [];

% Define the shifts in indices to find neighbors
shifts = [-1, 0, 0; 1, 0, 0; 0, -1, 0; 0, 1, 0; 0, 0, -1; 0, 0, 1];

% Initialize a matrix to track visited vertices
visited = false(num_values, num_values, num_values);

% Loop through all vertices and connect to neighbors
for i = 1:num_vertices
    % Get the coordinates of the current vertex
    xi = p_ha_values(i);
    yi = prior_a_values(i);
    zi = omega_values(i);
    
    % Mark the current vertex as visited
    [x_idx, y_idx, z_idx] = ind2sub([num_values, num_values, num_values], i);
    visited(x_idx, y_idx, z_idx) = true;
    
    % Loop through neighboring shifts
    for s = 1:size(shifts, 1)
        x_shift = shifts(s, 1);
        y_shift = shifts(s, 2);
        z_shift = shifts(s, 3);
        
        x_neighbor = x_idx + x_shift;
        y_neighbor = y_idx + y_shift;
        z_neighbor = z_idx + z_shift;
        
        % Check if the neighbor is within bounds and not visited
        if x_neighbor >= 1 && x_neighbor <= num_values && ...
           y_neighbor >= 1 && y_neighbor <= num_values && ...
           z_neighbor >= 1 && z_neighbor <= num_values && ...
           ~visited(x_neighbor, y_neighbor, z_neighbor)
        
            neighbor_idx = sub2ind([num_values, num_values, num_values], x_neighbor, y_neighbor, z_neighbor);
            
            % Get the coordinates of the neighbor
            xj = p_ha_values(neighbor_idx);
            yj = prior_a_values(neighbor_idx);
            zj = omega_values(neighbor_idx);
            
            % Calculate the weight using the sim_behavior_different function
            weight = sim_behavior_different(struct('p_ha', xi, 'prior_a', yi, 'omega', zi), ...
                                            struct('p_ha', xj, 'prior_a', yj, 'omega', zj));
            fprintf('Weight: %f \n',weight)

            % Store the edge information
            edges = [edges; i, neighbor_idx, weight];
        end
    end
end

% Define the vertices in 3D space
X = p_ha_values;
Y = prior_a_values;
Z = omega_values;

% Create a 3D scatter plot for the vertices
scatter3(X, Y, Z, 'filled');

% Define a colormap for edge colors based on weights
colormap_edge = jet;  % You can choose a different colormap if desired

% Normalize the weights to map them to the colormap
normalized_weights = edges(:, 3) / max(edges(:, 3));

% Plot the edges with colors based on normalized weights
for k = 1:size(edges, 1)
    i = edges(k, 1);
    j = edges(k, 2);
    normalized_weight = normalized_weights(k);
    
    % Map the normalized weight to the colormap
    color_idx = round(normalized_weight * (size(colormap_edge, 1) - 1)) + 1;
    edge_color = colormap_edge(color_idx, :);
    
    line([X(i), X(j)], [Y(i), Y(j)], [Z(i), Z(j)], 'Color', edge_color, 'LineWidth', 1);
end

% Set axis labels and title
xlabel('p_ha');
ylabel('prior_a');
zlabel('omega');
title('3D Cube with Varying Edge Colors');
colorbar;  % Add a colorbar to indicate the weight scale



function [num_diff] = sim_behavior_different(priors_one, priors_two)
    load('trialinfo_forty_eighty.mat');
    % save the current random number seed
    current_rng = rng;
    mdp = advise_gen_model(trialinfo_forty_eighty(1:30,:), priors_one);
    MDP = spm_MDP_VB_X_advice_no_message_passing(mdp);
    sim_one = {MDP.u};
    % use the same random number seed from before
    rng(current_rng);
    mdp = advise_gen_model(trialinfo_forty_eighty(1:30,:), priors_two);
    MDP = spm_MDP_VB_X_advice_no_message_passing(mdp);
    sim_two = {MDP.u};

    different_trials = [];
    
    for col = 1:numel(sim_one)
        % Check if the contents of the cells are different
        if ~isequal(sim_one{col}, sim_two{col})
            % If different, store the column number
            different_trials = [different_trials, col];
        end
    end
    num_diff = length(different_trials);
end