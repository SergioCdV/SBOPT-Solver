%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Cost function %% 
% Function implementation of a cost function 

function [M, L] = CostFunction(params, beta, t0, tf, s, u)
    M = 0; 
    L = 0.5*dot(u,u,1);
end