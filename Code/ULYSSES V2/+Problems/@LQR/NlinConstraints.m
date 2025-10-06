%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Inequality constraints
    c = []; 

    % Equality constraints
    ceq = [t(1,1) - params(1); t(1,end) - params(2)];     % Constraint on the initial and final clocks
end