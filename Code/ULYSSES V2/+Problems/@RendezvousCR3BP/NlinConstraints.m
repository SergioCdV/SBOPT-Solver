%% ULYSSES %%
% Date: 07/02/2023

%% Nonlinear Constraints %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t, x, u)
    % Constants 
    t0 =   params.T0;         % Initial clock
    tf =   params.TF;         % Final clock

    % Inequality constraints
    c = [];   

    % Equality constraints
    ceq = [t(1,1) - t0; t(1,end) - tf];         
end