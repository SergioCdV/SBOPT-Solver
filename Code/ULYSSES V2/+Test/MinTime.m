%% ULYSSES %%
% Date: 28/03/25

%% Moon Landing %% 
% This script provides a main interface to solve the Moon Landing problem via a pseudospectral method %

%% Set up
close all
clear
rng(1)

%% Problem definition
% Pre-amble
StateDimension = 2;             % Dimension of the state vector
ControlDimension = 1;           % Dimension of the control vector

% Problem parameters
Tmax = 1;

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 100;                          % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
% Create the problem
problem_params(1) = Tmax;      % Maximum thrust
S0 = [0; 0];                   % Initial conditions
SF = [1; 0];                   % Final conditions

OptProblem = Problems.MinTime(StateDimension, ControlDimension, problem_params, S0, SF);

% Initial guess 
X0 = [ones(1, (m + 1)); ones(1, (m + 1)); ones(1, (m + 1))];
Z0 = [reshape(X0, [], 1); zeros( (m + 1) * (ControlDimension), 1 ); 0; 1];

% Solve the problem
tic
[x, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
toc 

%% Plots
figure;
hold on
plot(x(1,:), x(2,:))
xlabel('$v$')
ylabel('$h$')
hold on
grid on; 
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));


figure;
hold on
plot(tau, u, 'LineWidth', 0.3)
yline(Tmax, 'k--')
xlabel('$t$')
ylabel('$T$')
grid on;
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));
