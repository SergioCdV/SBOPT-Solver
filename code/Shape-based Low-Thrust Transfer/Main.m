%% Project: 
% Date: 01/02/22

%% Main script
% Version 5 
% Following the paper "Initial design..." by Fan et. al

% This script aims to perform trajectory design optimisation processes
% based on Bernstein polynomials collocation methods

%% Graphics
set_graphics(); 
close all

animations = 0;     % Set to 1 to generate the gif
fig = 1;            % Figure start number

%% Variables to be defined for each run
m = 60;                                 % Number of discretization points
time_distribution = 'Linear';           % Distribution of time intervals
sigma = 1;                              % If normal distribution is selected

%% Collocation method 
% Order of Bezier curve functions for each coordinate
%n = [5 5 5 5 5 5];
n = [12 12 12];

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
% Gravitational parameter of the body
mu = 1; 

% Thruser/accleration and spacecraft mass data
T = 4e-2; 
m0 = 1/T; 
Isp = 0.07/T;

% Earth orbital element 
coe_earth = [1 0 0 0 0]; 
s = coe2state(mu, [coe_earth deg2rad(90)]);
initial = cylindrical2cartesian(s, false).';

% Mars orbital elements 
coe_mars = [1.5 0.09 deg2rad(0) deg2rad(2) 0]; 
s = coe2state(mu, [coe_mars deg2rad(260)]);
final = cylindrical2cartesian(s, false).';

% Initial guess for the boundary control points
[Papp, ~, Capp, tfapp] = initial_approximation(mu, tau, n, T, initial, final, 'Bernstein');
tfapp = 2*pi*(800/365); 

% Initial fitting for n+1 control points
[B, P0, C0] = initial_fitting(n, tau, Capp, 'Bernstein');

%% Optimisiation
% Initial guess 
x0 = reshape(P0, [size(P0,1)*size(P0,2) 1]);
x0 = [x0; tfapp];
L = length(x0)-1;

% Upper and lower bounds (empty in this case)
P_lb = [-Inf*ones(L,1); 0];
P_ub = [Inf*ones(L,1); Inf];

% Objective function
objective = @(x)cost_function(initial, final, mu, T,x,B,m,n,tau);

% Linear constraints
A = [];
b = [];
Aeq = [];
beq = [];

% Non-linear constraints
nonlcon = @(x)constraints(mu, m0, 2*pi*(800/365), T, tau, initial, final, n, m, x, B);

% Modification of fmincon optimisation options and parameters (according to the details in the paper)
options = optimoptions('fmincon', 'TolCon', 1e-6, 'Display', 'iter-detailed', 'Algorithm', 'sqp');
options.MaxFunctionEvaluations = 1e6;

% Optimisation
[sol, dV, exitflag, output] = fmincon(objective, x0, A, b, Aeq, beq, P_lb, P_ub, nonlcon, options);

% Solution 
P = reshape(sol(1:end-1), [size(P0,1) size(P0,2)]);
tf = sol(end);
P(:,1) = initial(1:3);
P(:,2) = initial(1:3)+tf*initial(4:6)./n;
P(:,end-1) = final(1:3)-tf*final(4:6)./n;
P(:,end) = final(1:3);
[c,ceq] = constraints(mu, m0, tf, T, tau, initial, final, n, m, sol, B);
C = evaluate_state(P,B,n);
r = sqrt(C(1,:).^2+C(3,:).^2);
time = tau*tf;
mass = m0-tf*Isp*tau;

% Control input
u = acceleration_control(mu,C,tf);
u = u/tf^2;

%% Results
display_results(exitflag, output, tfapp, tf);
plots(); 