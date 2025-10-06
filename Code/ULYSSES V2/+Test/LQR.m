%% ULYSSES %%
% Date: 28/03/25

%% Kalman LQR %% 
% This script provides a main interface to solve Kalman's LQR problem via a pseudospectral method %

%% Set up
close all
clear
rng(1)

%% Problem definition 
% Pre-amble
StateDimension = 2;             % Dimension of the state vector
ControlDimension = 3;           % Dimension of the control vector

% Boundary conditions
SF = zeros(StateDimension,1);   % Final conditions

% Problem parameters
tf = 100; 

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 4;                         % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
n_problems = 1;    
k = 1;

% Sampling of the initial conditions
Sigma = eye(StateDimension);
r0 = mvnrnd(zeros(StateDimension,1), Sigma, n_problems).';
TOF = 20 + 80 * rand(1,n_problems);

tic
for i = 1:n_problems
    % Create the problem
    TOF(i) = 1;
    problem_params(1) = 0;         % Initial time
    problem_params(2) = TOF(i);    % Final TOF
    S0 = r0(:,i);                  % Initial conditions

    S0 = [0; 0];
    SF = [1; 0];

    OptProblem = Problems.LQR(StateDimension, ControlDimension, problem_params, S0, SF);

    % Initial guess 
    Z0 = ones( (m + 1) * (StateDimension + ControlDimension) + 2, 1 );
    
    % Solve the problem
    tic
    [x, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
    toc 

    % Save the solution
    if ( (exitflag == 1) || (exitflag == 2) || (exitflag == 3) )
        State{k} = x; 
        control{k} = u; 
        time{k} = tau;
        k = k+1;
    end
end
toc

%% Plots
figure;
hold on
plot(tau, x(1:StateDimension/2,:))
xlabel('$t$')
ylabel('$\mathbf{r}$')
hold on
grid on; 
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));

figure_orbits = figure;
hold on
plot(tau, x(StateDimension/2+1:end,:))
plot(tau, -12*tau.^2/2 + 6 * tau, '*')
xlabel('$t$')
ylabel('$\dot{\mathbf{r}}$')
hold on
grid on;
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));

figure;
hold on
% plot(tau, sqrt(dot(u, u, 1)), 'k', 'LineWidth', 1)
plot(tau, u, 'LineWidth', 0.3)
xlabel('$t$')
ylabel('$\mathbf{u}$')
legend('$\|u\|_2$', '$u_1$', '$u_2$', '$u_3$')
grid on;
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));
