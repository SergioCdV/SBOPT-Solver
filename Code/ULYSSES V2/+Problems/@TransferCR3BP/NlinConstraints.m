%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Constants 
    Tmax = params(2,1);         % Maximum thrust
    t0 =   params(3,1);         % Initial clock
    tf =   params(4,1);         % Final clock

    % Inequality constraints
    c = [dot(u, u, 1) - Tmax^2];   

    % Equality constraints
    ceq = [t(1,1) - t0; t(1,end) - tf];         
end