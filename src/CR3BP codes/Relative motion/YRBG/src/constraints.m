%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 30/01/2022

%% Constraints %% 
% Function to compute the residual vector of the constraints of the problem

% Inputs: - array final_orbit, the final desired orbit
%         - scalar mu, the gravitational parameter of the central body 
%         - scalar T, the maximum acceleration allowed for the spacecraft
%         - vector initial, the initial boundary conditions of the
%           trajectory 
%         - vector n, the vector of degrees of approximation of the state
%           variables
%         - vector x, the degree of freedom to be optimized 
%         - cell array B, the polynomial basis to be used
%         - string basis, the polynomial basis to be used
%         - vector tau, the vector of collocation points
%         - string sampling_distribution, the sampling distribution to be used
%         - string dynamics, the dynamics vectorfield parametrization to be
%           used

% Outputs: - inequality constraint residual vector c
%          - equality constraint residual vector ceq

function [c, ceq] = constraints(curve, cost, mu, St, T, initial, n, x, B, basis, tau, sampling_distribution, dynamics)
    % Extract the optimization variables
    P = reshape(x(1:end-3), [length(n), max(n)+1]);     % Control points
    tf = x(end-2);                                      % Final time of flight on the unstable manifold 
    N = floor(x(end-1));                                % Optimal number of revolutions

    % Evaluate the initial periodic trajectory 
    St.Trajectory = target_trajectory(sampling_distribution, tf, tau, St.Period, [St.Cp; St.Cv]);

    % Compute the insertion phase and final conditions
    theta = x(end);                                     % Optimal insertion phase
    final = final_orbit(curve, theta);
    final = final-St.Trajectory(:,end);
    final = cylindrical2cartesian(final, false).';

    % Boundary conditions points
    P = boundary_conditions(sum(tf), n, initial, final, N, P, B, basis);

    % Trajectory evolution
    C = evaluate_state(P,B,n);
    S = cylindrical2cartesian(C(1:6,:), true);

    % Control input 
    [u, dv] = acceleration_control(mu, St, C, sum(tf), dynamics);

    % Equalities
    switch (cost)
        case 'Minimum power'
            ceq = trapz(tau, dot(dv,u,1));
        otherwise
            ceq = [];
    end

    % Inequality (control authority)
    switch (dynamics)
        case 'Sundman'
            c = [sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2)-(sum(tf)^2*T*r.^2.*ones(1,size(u,2)))]; 
        case 'Euler'
            c = [sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2)-(sum(tf)^2*T*ones(1,size(u,2)))];
        otherwise
            error('No valid dynamics formulation was selected');
    end

%     % Poincare map constraint 
%     STM = stm_computation(mu, tf, St, n, zeros(length(n), length(tau)), B, sampling_distribution, basis, tau, 'Numerical');
%     [V, ~] = eig(reshape(STM(:,end), [6 6])); 
%     alpha = V^(-1)*S(:,end);
% 
%     ceq = [ceq real(alpha(1))];
% 
%     % Unstable manifold departure constraint 
%     STM = stm_computation(mu, tf, St, n, P, B, sampling_distribution, basis, tau, 'Numerical');
%     [V, ~] = eig(reshape(STM(:,2), [6 6])); 
%     alpha = V^(-1)*S(:,2);
% 
%     ceq = [ceq real(alpha(2))];
end