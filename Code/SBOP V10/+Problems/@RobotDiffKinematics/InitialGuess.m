%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Initial guess function %% 
% Function implementation of the a warming up initial guess if available

function [beta, t0, tf] = InitialGuess(obj, params, initial, final)    
    % Initial guess
    t0 = params(1);            % Initial clock
    tf = params(2);            % Final clock
    beta = initial;            % Initial guess for the final boundary condition
end