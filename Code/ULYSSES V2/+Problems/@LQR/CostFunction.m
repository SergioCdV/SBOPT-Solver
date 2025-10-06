%% ULYSSES %%
% Date: 07/02/2023

%% Cost function %% 
% Function implementation of the cost function 

function [M, L] = CostFunction(obj, params, beta, t, x, u)
    M = 0; 
    L = 0.5 * dot(u, u, 1);
end