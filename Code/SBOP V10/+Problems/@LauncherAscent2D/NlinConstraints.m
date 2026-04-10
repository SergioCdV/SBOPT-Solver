%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Constraints function %% 
% Function implementation of the path and boundary constraints functions

function [c, ceq] = NlinConstraints(obj, params, beta, t0, tf, tau, s, u)
    % Inequality constraints
    c = [dot(u,u,1)-params(3)^2 -s(1,:), s(1,:) - s(1,end), -s(4,:), -s(3,:), tf - 4 * 3600];
   
    % Equality constraints
    ceq = [];
end