%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Uppe an lower bounds function %% 
% Function implementation the definition of the upper na dlowe bounds for
% the problem

function [LB, UB] = BoundsFunction(obj)
    % Upper and lower bounds for the problem first order state vector, initial time, final time and parameters
    LB = [-Inf * ones(1,7)   0   0 -Inf * ones(1,2)];
    UB = [+Inf * ones(1,7) Inf Inf +Inf * ones(1,2)];
end