%% Project: 
% Date: 19/05/22

%% Shapse-based optimization %%
% Function to compute the low-thrust orbital transfer using a polynomial
% shape-based approach

% Inputs: - structure system, containing the physical information of the
%           2BP of interest
%         - vector initial_coe, the initial orbital elements 
%         - vector final_coe, the final orbital elements 
%         - scalar K, an initial desired revolutions value 
%         - scalar T, the maximum allowed acceleration 
%         - structure setup, containing the setup of the algorithm in general

% Outputs: - array C, the final state evolution matrix
%          - scalar dV, the final dV cost of the transfer 
%          - array u, a 3xm matrix with the control input evolution  
%          - scalar tf, the final time of flight 
%          - scalar tfapp, the initial estimated time of flight 
%          - vector tau, the time sampling points final distribution
%          - exitflag, the output state of the optimization process 
%          - structure output, containing information on the final state of
%            the optimization process

function [C, dV, u, tf, tfapp, tau, exitflag, output] = sb_solver(system, initial_coe, final_coe, TOF, T, setup)
    % Setup of the algorithm
    n = setup.order;                        % Order in the approximation of the state vector
    basis = setup.basis;                    % Polynomial basis to be used 
    sampling_distribution = setup.grid;     % Sampling grid to be used
    m = setup.nodes;                        % Number of nodes in the grid
    cost = setup.cost_function;             % Cost function to be minimized
    time_free = setup.FreeTime;             % Free or time-fixed problem

    % Characteristics of the system 
    mu = system.mu;                         % Characteristic gravitational parameter
    r0 = system.distance;                   % Characteristic distance
    t0 = system.time;                       % Characteristic time

    % Approximation order 
    if (length(n) == 1)
        n = repmat(n, [1 5]);
    end

    % Boundary conditions 
    s = coe2state(mu, initial_coe);                     % Initial state vector 
    initial = cylindrical2cartesian(s, false).';        % Initial state vector in cylindrical coordinates
    s = coe2state(mu, final_coe);                       % Final state vector                   
    final = cylindrical2cartesian(s, false).';          % Final state vector in cylindrical coordinates 
    
    % Initial TOF
    if (time_free)
        tfapp = initial_tof(mu, T, initial, final);
    else
        tfapp = max(TOF,0);
    end

    % Normalization
    gamma = r0/(t0/(1))^2;                              % Characteristic acceleration of the system
    mu = mu*(t0^2/r0^3);                                % Gravitational parameter of the body
    system.mu = mu; 

    tfapp = tfapp/t0;                                   % Time of flight
    T = T/gamma;                                        % Spacecraft propulsion parameters 

    initial_coe(1) = initial_coe(1)/r0;                                   % Boundary conditions normalization
    s = coe2state(mu, initial_coe);                                       % Initial state vector 
    initial_u = state_mapping(s, true).';                                 % Initial conditions in the u space
    initial_u = [initial_u(1:4) -mu/(2*initial_coe(1)) initial_u(5:8)];   % Initial energy constraint

    final_coe(1) = final_coe(1)/r0;                                       % Boundary conditions normalization
    s = coe2state(mu, final_coe);                                         % Final state vector     
    final_u = state_mapping(s, true).';                                   % Final conditions in the u space
    final_u = [final_u(1:4) -mu/(2*final_coe(1)) final_u(5:8)];           % Initial energy constraint

    % Initial guess for the boundary control points
    mapp = 300;   
    tapp = sampling_grid(mapp, sampling_distribution, '');
    [~, Capp, sfapp] = initial_approximation(tapp, tfapp, initial_u, final_u, basis); 
    
    % Initial fitting for n+1 control points
    [P0, ~] = initial_fitting(n, tapp, Capp, basis);
    
    % Quadrature definition
    [tau, W, J] = quadrature(n, m, sampling_distribution);

    % Final TOF scaling
    tfapp = tfapp*J;

    % Final state basis
    [B, tau] = state_basis(n, tau, basis);

    % Initial guess reshaping
    x0 = reshape(P0, [size(P0,1)*size(P0,2) 1]);
    L = length(x0);
    x0 = [x0; final_u([1:4 6:9]).'; 0; 0; sfapp; T];
   
    % Upper and lower bounds 
    if (time_free)
        tol = 1e-8/gamma;
        P_lb = [-Inf*ones(L,1); -Inf*ones(8,1); -Inf; -Inf; 0; T-tol];
        P_ub = [Inf*ones(L,1); Inf*ones(8,1); Inf; Inf; Inf; T+tol];
    else
        P_lb = [-Inf*ones(L,1); -Inf*ones(8,1); -Inf; -Inf; 0; 0];
        P_ub = [Inf*ones(L,1); Inf*ones(8,1); Inf; Inf; Inf; 1/gamma];
    end

    % Final conditions
    s = coe2state(mu, final_coe);                       % Final state vector                   
    final = cylindrical2cartesian(s, false).';          % Final state vector in cylindrical coordinates 
    final = [final(1:3) final_u(4) final(4:6)];
    
    % Objective function
    objective = @(x)cost_function(cost, mu, initial_u, final, B, basis, n, tau, W, x);

    % Non-linear constraints
    nonlcon = @(x)constraints(mu, initial_u, final, tfapp, time_free, B, basis, n, tau, x);
    
    % Linear constraints and inequalities
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    % Modification of fmincon optimisation options and parameters (according to the details in the paper)
    options = optimoptions('fmincon', 'TolCon', 1e-6, 'Display', 'off', 'Algorithm', 'sqp');
    options.MaxFunctionEvaluations = 1e6;
    
    % Optimisation
    [sol, dV, exitflag, output] = fmincon(objective, x0, A, b, Aeq, beq, P_lb, P_ub, nonlcon, options);
    
    % Solution 
%     P = reshape(sol(1:end-5), [size(P0,1) size(P0,2)]);     % Optimal control points
%     thetaf = sol(end-4);                                    % Final fiber angle
%     dE0 = sol(end-2);                                       % Initial energy derivative
%     dEf = sol(end-3);                                       % Final energy derivative
%     sf = sol(end-1);                                        % Optimal time of flight in Sundman transformation
%     T = sol(end);                                           % Needed thrust vector
%     
%     % Final control points imposing boundary conditions
%     R = [cos(thetaf) 0 0 -sin(thetaf); 0 cos(thetaf) sin(thetaf) 0; 0 -sin(thetaf) cos(thetaf) 0; sin(thetaf) 0 0 cos(thetaf)];
%     final(1:4) = final(1:4)*R.';
%     final(6:9) = final(6:9)*R.';

    P = reshape(sol(1:end-12), [length(n), max(n)+1]);     % Control points
    thetaf = sol(end-11:end-4);                                  % Final fiber angle
    dE0 = sol(end-3);                                     % Initial energy derivative
    dEf = sol(end-2);                                     % Final energy derivative
    sf = sol(end-1);                                      % Final time of flight 
    T = sol(end);                                         % Needed thrust vector

    initial_u = [initial_u dE0];
    final_u = [thetaf(1:4).' final(4) thetaf(5:8).' dEf];
    P = boundary_conditions(sf, n, initial_u, final_u, P, B, basis);
    
    % Final state evolution
    C = evaluate_state(P,B,n);

    % Dimensional velocity 
    C(6:10,:) = C(6:10,:)/sf;

    % Dimensional control input
    r = dot(C(1:4,:),C(1:4,:),1);
    u = acceleration_control(mu, C, sf) / sf^2;
    for i = 1:size(C,2)
        L = KS_matrix(C(1:4,i));
        u(:,i) = L*u(:,i)/r(i);
    end
    u = u(1:3,:);

    % Transformation to the Cartesian space 
    C = state_mapping(C, false);

    % Sundman transformation 
    t = sf*cumtrapz(tau,dot(C(1:4,:),C(1:4,:),1));
    tf = t(end);
    
    % Time domain normalization and scale preserving
    switch (sampling_distribution)
        case 'Chebyshev'
            tau = (1/2)*(1+tau);
            tf = tf/J;
            tfapp = tfapp/J;
        case 'Legendre'
            tau = (1/2)*(1+tau);
            tf = tf/J;
            tfapp = tfapp/J;
        otherwise
    end

    % Results 
    if (setup.resultsFlag)
        display_results(exitflag, cost, output, r0, t0, tfapp, t(end), dV);
        plots(system, tf, tau, C, u, T, initial_coe, final_coe, setup);
    end
end
