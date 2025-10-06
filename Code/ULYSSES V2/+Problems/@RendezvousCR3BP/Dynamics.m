%% ULYSSES %%
% Date: 07/02/2023

%% Dynamics %% 
% Function implementation of the dynamics vector field

function [f] = Dynamics(obj, params, beta, t, x, u)
    % Constants 
    A = params.A; 
    B = params.B;
    
    % Linear vectorfield
    f = A * x + B * u;
end