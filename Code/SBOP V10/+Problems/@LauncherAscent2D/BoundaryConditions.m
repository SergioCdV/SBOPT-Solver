%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Boundary Conditions function %% 
% Function implementation of the boundary conditions definition

function [s0, sf] = BoundaryConditions(obj, initial, final, params, beta, t0, tf)
    s0          = initial;
    sf          = final;
    sf(end-1)   = beta(1);    % Free geocentric angle
    sf(end)     = beta(2);    % Free final mass
end