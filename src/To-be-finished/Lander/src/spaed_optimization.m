%% Project: 
% Date: 19/05/22

%% Shapse-based optimization %%
% Function to compute the low-thrust orbital transfer using a polynomial
% shape-based approach

% Inputs: - structure system, containing the physical information of the
%           2BP of interest
%         - vector initial, the initial Cartesian state vector
%         - vector final, the final Cartesian state vector
%         - scalar T, the maximum allowed acceleration
%         - scalar m, the number of sampling nodes to use 
%         - string sampling_distribution, to select the sampling distribution
%           to use 
%         - string basis, the polynomial basis to be used in the
%           optimization
%         - scalar n, the polynomial degree to be used 
%         - structure setup, containing the setup of the figures

% Outputs: - array C, the final state evolution matrix
%          - scalar dV, the final dV cost of the transfer 
%          - array u, a 3xm matrix with the control input evolution  
%          - scalar tf, the final time of flight 
%          - scalar tfapp, the initial estimated time of flight 
%          - vector tau, the time sampling points final distribution
%          - exitflag, the output state of the optimization process 
%          - structure output, containing information on the final state of
%            the optimization process

function [C, dV, u, tf, tfapp, tau, exitflag, output] = spaed_optimization(system, initial, final, T, m, sampling_distribution, basis, n, setup)
    % Characteristics of the system 
    mu = system.mu;             % Characteristic gravitational parameter
    r0 = system.distance;       % Characteristic distance
    t0 = system.time;           % Characteristic time
    a = system.ellipsoid;       % Semimajor axes of the ellipsoid

    % Approximation order 
    if (length(n) == 1)
        n = repmat(n, [1 3]); 
    end

    % Initial TOF
    tfapp = initial_tof(mu, T, initial, final);

    % Normalization
    % Gravitational parameter of the body
    mu = mu*(t0^2/r0^3);
    a = a/r0;
    
    % Boundary conditions
    initial = initial/r0;
    final = final/r0;
        
    % Time of flight
    tfapp = tfapp/t0;
    
    % Spacecraft propulsion parameters 
    T = T*(t0^2/r0);

    % Core optimization
    % Initial guess for the boundary control points
    mapp = 300;   
    tapp = sampling_grid(mapp, sampling_distribution, '');
    [~, Capp] = initial_approximation(tapp, tfapp, initial, final, basis); 
    
    % Initial fitting for n+1 control points
    [P0, ~] = initial_fitting(n, tapp, Capp, basis);
    
    % Final collocation grid and basis 
    tau = sampling_grid(m, sampling_distribution, '');
    [B, tau] = state_basis(n, tau, basis);

    % Initial guess 
    x0 = reshape(P0, [size(P0,1)*size(P0,2) 1]);
    L = length(x0);
    x0 = [x0; tfapp];
    
    % Upper and lower bounds (empty in this case)
    P_lb = [-Inf*ones(L,1); 0];
    P_ub = [Inf*ones(L,1); Inf];
    
    % Objective function
    objective = @(x)cost_function(a, mu, initial, final, n, tau, x, B, basis, sampling_distribution);
    
    % Linear constraints
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    % Non-linear constraints
    nonlcon = @(x)constraints(mu, a, T, initial, final, n, x, B, basis);
    
    % Modification of fmincon optimisation options and parameters (according to the details in the paper)
    options = optimoptions('fmincon', 'TolCon', 1e-6, 'Display', 'iter-detailed', 'Algorithm', 'sqp');
    options.MaxFunctionEvaluations = 1e6;
    
    % Optimisation
    [sol, dV, exitflag, output] = fmincon(objective, x0, A, b, Aeq, beq, P_lb, P_ub, nonlcon, options);
    
    % Solution 
    P = reshape(sol(1:end-1), [size(P0,1) size(P0,2)]);     % Optimal control points
    tf = sol(end);                                          % Optimal time of flight
    
    P = boundary_conditions(tf, n, initial, final, P, B, basis);
    
    % Final state evolution
    C = evaluate_state(P,B,n);
    
    % Control input
    u = acceleration_control(mu,C,tf,a);
    u = u/tf^2;

    % Time domain normalization 
    switch (sampling_distribution)
        case 'Chebyshev'
            tau = (1/2)*(1+tau);
            tf = tf*2;
        case 'Legendre'
            tau = (1/2)*(1+tau);
            tf = tf*2;
        case 'Laguerre'
            tau = collocation_grid(m, 'Legendre', '');
            tau = (1/2)*(1+tau);
            tf = tf*2;
    end

    % Results 
    if (setup.resultsFlag)
        display_results(exitflag, output, r0, t0, tfapp, tf, dV);
        plots(system, tf, tau, C, u, T, initial, final, setup);
    end
end
 

%% Auxiliary functions 
% Compute the derivative of time with respect to the generalized anomaly 
function [dt] = Sundman_transformation(basis, n, P, t, s)
    B = state_basis(n,s,basis);
    C = evaluate_state(P,B,n);
    dt = sqrt(C(1,:).^2+C(3,:).^2);
end