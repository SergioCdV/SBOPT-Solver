%% ULYSSES %%
% Date: 07/02/2023

%% Dynamics %% 
% Function implementation of the dynamics vector field

function [f] = Dynamics(obj, params, beta, t, x, u)
    % Constants 
    mu = params(1);                   % Gravitational parameter of the system
    Sigma = [0 2 0; -2 0 0; 0 0 0];   % Coriolis dyadic

    R = [-mu 1-mu; 0 0; 0 0];         % Location of the primaries
    Rr(1:3,:) = x(1:3,:) - R(:,1);    % Relative position to the first primary
    Rr(4:6,:) = x(1:3,:) - R(:,2);    % Relative position to the second primary

    % Vector field
    Fg = -(1-mu) * Rr(1:3,:) ./ sqrt( dot(Rr(1:3,:), Rr(1:3,:), 1) ).^3 -mu * Rr(4:6,:) ./ sqrt( dot(Rr(4:6,:), Rr(4:6,:), 1) ).^3;
        
    f(1:3,:) = x(4:6,:);
    f(4:6,:) = [x(1:2,:); zeros(1,size(x,2))] + Sigma * x(4:6,:) + Fg + u;
end