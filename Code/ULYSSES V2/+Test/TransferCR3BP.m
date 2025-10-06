%% ULYSSES %%
% Date: 28/03/25

%% Transfer in the CR3BP %% 
% This script provides a main interface to solve the CR3BP problem via a pseudospectral method %

%% Set up
close all
clear
rng(1)

%% Problem definition
% Pre-amble
StateDimension = 6;             % Dimension of the state vector
ControlDimension = 3;           % Dimension of the control vector

% Problem parameters
mu = 0.0125;                    % Gravitational parameter of the system
Tmax = 4;                    % Maximum acceleration

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 50;                          % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
% Create the problem
problem_params(1,1) = mu;        % Specific impulse
problem_params(2,1) = Tmax;      % Maximum thrust
problem_params(3,1) = 0;         % Initial time
problem_params(4,1) = 2*pi;        % Final time

% Initial conditions
S0 = [0.824024728136525; 0; -0.054501847320725; 0; 0.164671964079122; 0];          

% Final conditions
SF = [0.823639438925721; 0; +0.043281569720089; 0; 0.152567980892620; 0]; 

OptProblem = Problems.TransferCR3BP(StateDimension, ControlDimension, problem_params, S0, SF);

% Initial guess 
X0 = repmat(SF, 1, m+1);
Z0 = [reshape(X0, [], 1); zeros( (m + 1) * (ControlDimension), 1 ); 0; 1];

% Solve the problem
tic
[x, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
toc 

%% Plots
figure;
view(3)
hold on
plot3(x(1,:), x(2,:), x(3,:))
xlabel('$x$')
ylabel('$y$')
zlabel('$z$')
hold on
grid on; 
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));

figure;
hold on
plot(tau, u, 'LineWidth', 0.3)
yline(Tmax, 'k--')
xlabel('$t$')
ylabel('$\mathbf{u}$')
grid on;
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));
