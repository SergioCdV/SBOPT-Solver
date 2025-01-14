%% Project: 
% Date: 31/01/22

%% Flight time %%
% Function to estimate the time of flight

% Inputs: - vector initial, the initial boundary conditions of the
%           trajectory 
%         - vector final, the initial boundary conditions of the
%           trajectory
%         - scalar mu, the gravitational parameter of the central body 
%         - vector x, the degree of freedom to be optimized 
%         - cell array B, the polynomial basis to be used 
%         - vector n, the vector of degrees of approximation of the state
%           variables
%         - vector tau, the vector of collocation points
%         - string basis, the polynomial basis to be used

% Outputs: - scalar r, the cost index to be optimized

function [r] = cost_function(mu, initial, final, n, tau,  x, B, basis)
    % Minimize the control input
    P = reshape(x(1:end-1), [length(n), max(n)+1]);   % The Bézier control points
    tf = x(end);                                      % The final time of flight

    % Boundary conditions
    P(:,[1 2 end-1 end]) = boundary_conditions(tf, n, initial, final, basis);

    % State evolution
    C = evaluate_state(P,B,n);

    % Control input
    u = acceleration_control(mu, C, tf); 
    a = abs(u)/tf^2;

    % Minimize the control input
    r = trapz(tau, a/tf);
end