%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Constants 
    Tmax = params(4,1);         % Maximum thrust
    t0 =   params(5,1);         % Initial clock
    tf =   params(6,1);         % Final clock
    Ac =   params(7,1);

    % Inequality constraints
    u = u * Ac;
    c = [u-Tmax; -u-Tmax];
    c = reshape(c, [], 1);

    % Equality constraints
    ceq = [t(1,1) - t0; t(1,end) - tf];         
end