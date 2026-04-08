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
mu = 0.0121505856;              % Gravitational parameter of the system
Tmax = 4;                       % Maximum acceleration

TargetPeriod = 2.761104629643622; 
ChaserPeriod = 2.754937512093445; 

Lc = 384399;

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 100;                         % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
% Create the problem
problem_params(1,1) = mu;                 % Specific impulse
problem_params(2,1) = Tmax;               % Maximum thrust
problem_params(3,1) = 0;                  % Initial time
problem_params(4,1) = ChaserPeriod;       % Final time

% Initial conditions
SF = [0.824024728136525; 0; -0.054501847320725; 0; 0.164671964079122; 0];          

% Final conditions
S0 = [0.823639438925721; 0; +0.043281569720089; 0; 0.152567980892620; 0]; 

OptProblem = Problems.TransferCR3BP(StateDimension, ControlDimension, problem_params, S0, SF);

% Initial guess 
X0 = repmat(SF, 1, m+1);
Z0 = [reshape(X0, [], 1); zeros( (m + 1) * (ControlDimension), 1 ); 0; 1];

% Solve the problem
tic
[x, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
toc 

save +Test\RendezvousCR3BP_MPC_PS_L2_N100

%% Plots
figure;
view(3)
hold on
scatter3(x(1,1) * Lc, x(2,1) * Lc, x(3,1) * Lc, 100, 'b', 'Marker', 'square');
scatter3(x(1,end) * Lc, x(2,end) * Lc, x(3,end) * Lc, 100, 'b', 'Marker', 'o');
plot3(x(1,:) * Lc, x(2,:) * Lc, x(3,:) * Lc)
legend('$\mathbf{r}_c(t_0)$', '$\mathbf{r}_c(t_f)$', '$\mathbf{r}_c(t)$', 'AutoUpdate', 'off');
xlabel('$X$ [km]')
ylabel('$Y$ [km]')
zlabel('$Z$ [km]')
hold on
grid on; 
% xticklabels(strrep(xticklabels, '-', '$-$'));
% yticklabels(strrep(yticklabels, '-', '$-$'));

figure;
hold on
stem(tau, vecnorm(u, 2, 1), 'filled', 'b')
%yline(Tmax, 'k--')
xlabel('$t$')
ylabel('$\|\mathbf{u}\|_2$ [-]')
grid on;
% xticklabels(strrep(xticklabels, '-', '$-$'));
% yticklabels(strrep(yticklabels, '-', '$-$'));
xlim([tau(1) tau(end)])
