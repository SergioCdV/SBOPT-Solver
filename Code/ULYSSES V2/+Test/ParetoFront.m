%% ULYSSES %%
% Date: 28/03/25

%% Transfer in the CR3BP %% 
% This script provides a main interface to solve the CR3BP problem via a pseudospectral method %

%% Set up
clear
rng(1)

%% Problem definition
% Pre-amble
StateDimension = 6;             % Dimension of the state vector
ControlDimension = 3;           % Dimension of the control vector

% Problem parameters
mu = 0.0125;                    % Gravitational parameter of the system
Tmax = 4;                     % Maximum acceleration

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 10;                          % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
% Create the problem
problem_params(1,1) = mu;        % Specific impulse
problem_params(2,1) = Tmax;      % Maximum thrust
problem_params(3,1) = 0;         % Initial time

% Initial conditions
S0 = [0.824024728136525; 0; -0.054501847320725; 0; 0.164671964079122; 0];          

% Final conditions
SF = [0.823639438925721; 0; +0.043281569720089; 0; 0.152567980892620; 0]; 

% Search space
tf = linspace(1, 2*pi, 500);
tf = flip(tf);

% Initial guess
X0 = repmat(SF, 1, m+1);
U0 = ones(ControlDimension, m+1);

% Pre-allocation 
cost = zeros(1,length(tf));

for i = 1:length(tf)
    % Update the problem
    problem_params(4,1) = tf(i);        % Final time
    OptProblem = Problems.TransferCR3BP(StateDimension, ControlDimension, problem_params, S0, SF);

    % Initial guess 
    Z0 = [reshape(X0, [], 1); reshape(U0, [], 1); 0; tf(i)];

    % Solve the problem
    tic
    [x, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
    toc 

    if ( exitflag == 2 || exitflag == 1 )
        cost(i) = J;

        % Update initial guess 
        X0 = x; 
        U0 = u;
    else
        cost(i) = NaN;
    end
end

%% Plots
figure 
plot(tf, cost, '--ob')
grid on; 
xlabel('$t_f$')
ylabel('$J$')