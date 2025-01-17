%% Project: 
% Date: 01/02/22

%% Main script
% Version 5 
% Following the paper "Initial design..." by Fan et. al

% This script aims to perform trajectory design optimisation processes
% based on Bernstein polynomials collocation methods

%% Graphics
set_graphics(); 

animations = 0;     % Set to 1 to generate the gif
fig = 1;            % Figure start number

%% Variables to be defined for each run
m = 300;                                 % Number of discretization points
time_distribution = 'Legendre-Gauss';    % Distribution of time intervals
sigma = 1;                               % If normal distribution is selected

%% Constraints
amax = 1.5e-4;                           % Maximum acceleration available [m/s^2]

%% Collocation method 
% Order of Bezier curve functions for each coordinate
n = [7 7 7];

%% Global constants
r0 = 149597870700;                      % 1 AU [m] (for dimensionalising)
mu = 1.32712440042e+20;                 % Gavitational parameter of the Sun [m^3 s^−2]

%% Initial definitions
% Generate the time interval discretization distribution
switch (time_distribution)
    case 'Linear'
        tau = linspace(0,1,m);
    case 'Normal'
        pd = makedist('Normal');
        pd.sigma = sigma;
        xpd = linspace(-3,3,m);
        tau = cdf(pd,xpd);
    case 'Random'
        tau = rand(1, m);
        tau = sort(tau);
    case 'Gauss-Lobatto'
        i = 1:m;
        tau = -cos((i-1)/(m-1)*pi);
        tau = (tau-tau(1))/(tau(end)-tau(1));
    case 'Legendre-Gauss'
        tau = LG_nodes(0,1,m);
    case 'Bezier'
        tau = B_nodes(0,1,m);
    case 'Orthonormal Bezier'
        tau = OB_nodes(0,1,m);
    otherwise
        error('An appropriate time array distribution must be specified')
end

%% Boundary conditions of the problem
% Initial data
[initial, final] = initial_data(r0, 1);

% Initial guess for the boundary control points
[tfapp, Papp, ~, Capp] = initial_approximation(mu, r0, amax, tau, initial, final, 'Orthogonal Bernstein');

% Initial fitting for n+1 control points
[B, P0, C0] = initial_fitting(n, tau, Capp, 'Orthogonal Bernstein');

%% Optimisiation
% Initial guess 
x0 = [reshape(P0, [size(P0,1)*size(P0,2) 1])];
x0 = [x0; tfapp];

% Upper and lower bounds (empty in this case)
P_lb = [-Inf*ones(length(x0)-1,1); 0*tfapp];
P_ub = [Inf*ones(length(x0)-1,1); Inf];

% Objective function
objective = @(x)velocity_variation(mu, r0, tau, x, B, n);

% Linear constraints
A = [];
b = [];
Aeq = [];
beq = [];

% Non-linear constraints
nonlcon = @(x)constraints(mu, initial, final, r0, n, x, B, amax);

% Modification of fmincon optimisation options and parameters (according to the details in the paper)
options = optimoptions('fmincon', 'TolCon', 1e-6, 'Display', 'off', 'Algorithm', 'sqp');
options.MaxFunctionEvaluations = 1e6;

% Optimisation
[sol, dV, exitflag, output] = fmincon(objective, x0, A, b, Aeq, beq, P_lb, P_ub, nonlcon, options);

% Solution 
P = reshape(sol(1:end-1), [size(P0,1) size(P0,2)]);
tf_final = sol(end);
[c,ceq] = constraints(mu, initial, final, r0, n, sol, B, amax);

%% Results
% State vector approximation calculation
C = evaluate_state(P,B,n);

% Results
display_results(P0, P, B, m, exitflag, output, x0(end), r0, n)
plots();
