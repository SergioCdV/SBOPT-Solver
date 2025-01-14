%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 31/01/22

%% Cost function %%
% Function to compute the cost function to be minimized

% Inputs: - string cost, the cost function to be minimized
%         - scalar mu, the gravitational parameter of the central body 
%         - vector initial, the initial boundary conditions of the
%           trajectory 
%         - vector final, the initial boundary conditions of the
%           trajectory
%         - vector n, the vector of degrees of approximation of the state
%           variables
%         - vector tau, the vector of collocation points
%         - vector x, the degree of freedom to be optimized 
%         - cell array B, the polynomial basis to be used 
%         - string basis, the polynomial basis to be used
%         - string dynamics, the independent variable parametrization to be
%           used

% Outputs: - scalar r, the cost index to be optimized

function [r] = cost_function(cost, mu, initial, final, n, tau, x, B, basis, dynamics)
    % Optimization variables
    tf = x(end-1);              % Final time of flight  
                              
    switch (cost)
        case 'Minimum time'
            switch (dynamics)
                case 'Sundman'
                    P = reshape(x(1:end-2), [length(n), max(n)+1]);                     % Control points
                    N = floor(x(end));                                                  % The optimal number of revolutions
                    P = boundary_conditions(tf, n, initial, final, N, P, B, basis);     % Boundary conditions control points
                    C = evaluate_state(P,B,n);                                          % State evolution
                    r = sqrt(C(1,:).^2+C(3,:).^2);                                      % Radial evolution
                    r = tf*trapz(tau,r);                                                % Final time of flight

                case 'Kepler'
                    r = tf;                                                             % Final time of flight
            end

        case 'Minimum fuel'
            % Minimize the control input
            P = reshape(x(1:end-2), [length(n), max(n)+1]);                             % Control points
            N = floor(x(end));                                                          % The optimal number of revolutions
            P = boundary_conditions(tf, n, initial, final, N, P, B, basis);             % Boundary conditions control points
            C = evaluate_state(P,B,n);                                                  % State evolution

            [u, ~, ~] = acceleration_control(mu, tau, C, tf, dynamics);                 % Control vector
            u = u/tf^2;                                                                 % Normalized control vector
        
            switch (dynamics)
                case 'Sundman'
                    r = sqrt(C(1,:).^2+C(3,:).^2);         % Radial evolution
                    u = u./(r.^2);                         % Dimensional acceleration

                case 'Kepler'
            end

            a = sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2);       % Non-dimensional acceleration norm
            
            % Cost function
            r = tf*trapz(tau,a); 
            
        case 'Minimum power'
            % Minimize the control input
            P = reshape(x(1:end-2), [length(n), max(n)+1]);                             % Control points
            N = floor(x(end));                                                          % The optimal number of revolutions
            P = boundary_conditions(tf, n, initial, final, N, P, B, basis);             % Boundary conditions control points
            C = evaluate_state(P,B,n);                                                  % State evolution

            [u, ~, ~] = acceleration_control(mu, tau, C, tf, dynamics);                 % Control vector
            u = u/tf^2;                                                                 % Normalized control vector
        
            switch (dynamics)
                case 'Sundman'
                    r = sqrt(C(1,:).^2+C(3,:).^2);         % Radial evolution
                    u = u./(r.^2);                         % Dimensional acceleration

                case 'Kepler'
            end

            a = sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2);       % Non-dimensional acceleration norm
            
            % Cost function
            r = tf*trapz(tau,a);

        otherwise 
            error('No valid cost function was selected to be minimized');
    end       
end
