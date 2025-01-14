%% Project: 
% Date: 31/01/22

%% Cost function %%
% Function to estimate the time of flight

% Inputs: - scalar mu, the gravitational parameter of the central body 
%         - vector initial, the initial boundary conditions of the
%           trajectory 
%         - vector final, the initial boundary conditions of the
%           trajectory
%         - array measurements, an mx4 matrix of measurements in the form
%           of epoch | 3D vector measurement
%         - vector x, the degree of freedom to be optimized 
%         - cell array B, the polynomial basis to be used 
%         - vector n, the vector of degrees of approximation of the state
%           variables
%         - string cost_policy, the policy to be minimized
%         - vector tau, the vector of collocation points
%         - string sampling_grid, the time distribution law to be used
%         - string basis, the polynomial basis to be used
%         - string dynamics, the parametrization of the dynamics
%           vectorfield to be used

% Outputs: - scalar r, the cost index to be optimized

function [r] = cost_function(mu, initial, final, measurements, n, x, B, cost_policy, tau, sampling_grid, basis, dynamics)
    % Minimize the control input
    P = reshape(x(1:end-2), [length(n), max(n)+1]);     % Control points
    tf = x(end-1);                                      % The final time of flight
    N = floor(x(end));                                  % The optimal number of revolutions

    % Boundary conditions
    P = boundary_conditions(tf, n, initial, final, N, P, B, basis);

    % Re-evaluate the measurement's epochs in case it is needed
    epochs = measurements(1,:)/tf; 

    switch (dynamics)
        case 'Regularized'
            options = odeset('RelTol', 2.25e-14, 'AbsTol', 1e-22);
            [~, epochs] = ode45(@(t,s)Sundman_transformation(n, basis, P, t, s), epochs, 0, options);
            epochs = epochs.';
    end

    % Time mapping
    switch (sampling_grid)
        case 'Chebyshev'
            epochs = 2*epochs-1;
        case 'Legendre'
            epochs = 2*epochs-1;
        case 'Laguerre'
            epochs = 2*epochs-1;
    end

    % Cost function
    switch (cost_policy)
        case 'Least Squares'
            % State evolution
            B = state_basis(n, epochs, basis);
            C = evaluate_state(P,B,n);
        
            % Compute the residuals 
            M = cylindrical2cartesian(C(1:3,:),true);
            M(1:3,:) = M(1:3,:)./sqrt(M(1,:).^2+M(2,:).^2+M(3,:).^2);
            e = measurements(2:4,:)-M(1:3,:);
            r = sum(dot(e,e,1));  

        case 'Dynamics residual'
            % State evolution
            C = evaluate_state(P,B,n);

            % Control input
            u = acceleration_control(mu,C,tf,dynamics);        

            % Control cost
            switch (dynamics)
                case 'Regularized'
                    r = sqrt(C(1,:).^2+C(3,:).^2);                   % Radial evolution
                    a = sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2);         % Non-dimensional acceleration
                    a = a./r;                                        % Dimensional acceleration
                otherwise
                    a = sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2);         % Dimensional acceleration
            end
            
            % Cost function
            r = trapz(tau,a)/tf; 

        otherwise 
            error('No valid cost function was selected');
    end
end

%% Auxiliary function
% Compute the Sundman transformation 
function [ds] = Sundman_transformation(n, basis, P, t, s)
    B = state_basis(n, t, basis);
    C = evaluate_state(P,B,n);
    ds = 1./sqrt(C(1,:).^2+C(3,:).^2);
end