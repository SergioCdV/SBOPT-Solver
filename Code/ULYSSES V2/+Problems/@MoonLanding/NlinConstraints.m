%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Inequality constraints
    c = [u - params(4); -u; -x(3,:)];   % Constraints on mass and thrust

    % Equality constraints
    ceq = [t(1,1) - params(1)];         % Constraint on the initial and final clocks
end