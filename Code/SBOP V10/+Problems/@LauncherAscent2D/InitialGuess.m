%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Initial guess function %% 
% Function implementation of the a warming up initial guess if available

function [beta, t0, tf] = InitialGuess(obj, params, initial, final)
    % New initial TOF
    t0   = 0;
    tf   = 4 * 3600;
    beta = [0; 4 * 3600];       % Final angle and mass
end