%% ULYSSES %%
% Date: 07/02/2023

%% Uppe an lower bounds function %% 
% Function implementation the definition of the upper and lower bounds for
% the problem

function [LB, UB] = BoundsFunction(obj)
    % Upper and lower bounds for the problem first order state vector, control vector, initial time, final time and parameters
    LB = [-Inf * ones(1,4) -Inf * ones(1,2) 0 0];
    UB = [+Inf * ones(1,4) +Inf * ones(1,2) 2*pi +Inf];
end