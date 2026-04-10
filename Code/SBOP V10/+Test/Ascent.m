%% Project: SBOPT %%
% Date: 10/04/26

%% Ascent %% 
% This script provides a main interface to solve an optimal launcher ascent trajectory %

%% Set up
close all
clear

%% Numerical solver definition 
basis = 'Legendre';                   % Polynomial basis to be use. Alternatively: Legendre, Bernestein, Orthogonal Bernstein
time_distribution = 'Legendre';       % Distribution of time intervals. Alternatively: Bernstein, Orthogonal Bernstein, Chebsyhev, Legendre, Linear, Newton-Cotes, Normal, Random, Trapezoidal
n = [9 9 9];                          % Polynomial order in the state vector expansion
m = 100;                               % Number of sampling points
 
solver = Solver(basis, n, time_distribution, m);

%% Input data 
mu   = 3.896E14;                  % Gravity parameter
hf   = 600E3;                     % Insertion altitude [m]
Re   = 6371E3;                    % Earth's radius [m]
vf   = sqrt( mu / (Re + hf) );    % Final tangential velocity
m0   = 1.5E5;                     % Initial propellant mass [kg]
Tmax = 5.5E6;                     % Max. thrust [N]
g0   = 9.81;                      % Reference gravity acceleration [m/s^2]
Isp  = 500;                       % Engine specific impulse [s]

%% Problem definition 
L = 2;                          % Degree of the dynamics (maximum derivative order of the ODE system)
StateDimension   = 3;           % Dimension of the configuration vector. Note the difference with the state vector
ControlDimension = 2;           % Dimension of the control vector

% Boundary conditions
S0 = [0; 0; m0; 0; 0; 0];       % Initial conditions
SF = [hf; 0; 0; 0; vf; 0];      % Final conditions (free final mass and angle)

% Problem parameters 
problem_params = [mu; Re; Tmax; Isp; g0];

% Create the problem
OptProblem = Problems.LauncherAscent2D(S0, SF, L, StateDimension, ControlDimension, problem_params);
    
%% Optimization
% Simple solution    
tic
[C, mf, u, t0, tf, tau, exitflag, output] = solver.solve(OptProblem);
toc 

% Average results 
iter = 0; 
time = zeros(1,iter);
setup.resultsFlag = false; 
for i = 1:iter
    tic 
    [C, dV, u, t0, tf, tau, exitflag, output] = solver.solve(OptProblem);
    time(i) = toc;
end

time = mean(time);

%% Plots
figure;
hold on
plot(tau, C(1,:)/1e3)
xlabel('Mission time')
ylabel('Altitude [km]')
hold off
grid on;

figure;
hold on
plot(tau, C(4:5,:)/1e3)
xlabel('Mission time')
ylabel('Velocities [km/s]')
hold off
grid on;

figure;
hold on
plot(tau, C(3,:))
xlabel('Mission time')
ylabel('Mass [kg]')
hold off
grid on;

% Propulsive acceleration plot
figure_propulsion = figure;
hold on
plot(tau, sqrt( dot(u,u,1) ) / 1E3, 'LineWidth', 0.3)
plot(tau, u/ 1E3, 'LineWidth', 0.3)
xline( Tmax/ 1E3, 'k--' )
xlabel('Flight time')
ylabel('Thrust program')
grid on;
xlim( [tau(1) tau(end)] )