%% ULYSSES %%
% Date: 07/02/2023

%% Cost function %% 
% Function implementation of the cost function 

function [M, L] = CostFunction(obj, params, beta, t, x, u)
    k = params(1)^2 / params(2)^3;                % True anomaly angular velocity
%     k = k / params(9,1);
    rho = 1 + params(3) * cos(t(1,:));            % Transformation parameter
%     olvlh = k * rho.^2;                           % Angular velocity of the target's LVLH frame
%     u = u .* ( rho ./ olvlh.^2 );
%     u = u * params(7,1);

    M = 0; 
    L = sum( abs(u), 1 ) ./ (k .* rho.^2);
end