%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Inequality constraints
    T = params(1); 
    c = [u - T];   

    % Equality constraints
    ceq = [t(1,1) - 0];         
end