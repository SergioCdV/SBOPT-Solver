%% ULYSSES %%
% Date: 30/01/2022

%% Bounds function %% 

% Inputs: - class Problem, defining the problem of interest

% Outputs: - vector P_lb, vector of lower bounds
%          - vector P_ub, vector of upper bounds

function [P_lb, P_ub] = opt_bounds(obj, Problem)
    % Upper and lower bounds
    [P_lb, P_ub] = Problem.BoundsFunction(); 

    % Augment it to account for the total number of decision variables 
    n = Problem.StateDim; 
    m = Problem.ControlDim;
    P_lb = [repmat( P_lb(1,1:n), 1, obj.N) repmat( P_lb(1,n+1:n+m), 1, obj.N) P_lb(1,n+m+1:end)];
    P_ub = [repmat( P_ub(1,1:n), 1, obj.N) repmat( P_ub(1,n+1:n+m), 1, obj.N) P_ub(1,n+m+1:end)];
end