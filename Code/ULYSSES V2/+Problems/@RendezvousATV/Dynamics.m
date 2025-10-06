%% ULYSSES %%
% Date: 07/02/2023

%% Dynamics %% 
% Function implementation of the dynamics vector field

function [f] = Dynamics(obj, params, beta, t, x, u)
    % Constants
    k = params(1)^2 / params(2)^3;                % True anomaly angular velocity
    rho = 1 + params(3) * cos(t(1,:));            % Transformation parameter
    olvlh = k * rho.^2;                           % Angular velocity of the target's LVLH frame

    % Compute the control vector as a dynamics residual (linear acceleration, TH relative motion model)
    u = u .* (rho ./ olvlh.^2);

    f(1:2,:) = x(3:4,:);
    f(3:4,:) = [2 * x(4,:); 3 ./ rho .* x(2,:) - 2 * x(3,:)] + u;
end