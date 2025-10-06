%% ULYSSES %%
% Date: 07/02/2023

%% Boundary Conditions %% 
% Function implementation of the boundary conditions

function [res] = BoundaryConditions(obj, params, beta, t0, tf, x)
    % Extract the boundary conditions from the parameters vector 
    X0 = obj.X0;                    % Initial known boundary conditions
    XF = obj.XF;                    % Final known boundary conditions

    % Compute the residuals to the boundary conditions
    res = [x(:,1) - X0; x(:,end) - XF] * params(8,1);
end