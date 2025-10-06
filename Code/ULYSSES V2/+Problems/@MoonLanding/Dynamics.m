%% ULYSSES %%
% Date: 07/02/2023

%% Dynamics %% 
% Function implementation of the dynamics vector field

function [f] = Dynamics(obj, params, beta, t, x, u)
    
    g = params(2); 
    Isp = params(3);

    f(1,:) = x(2,:);
    f(2,:) = - g + u ./ x(3,:);
    f(3,:) = - u ./ (g * Isp);
end