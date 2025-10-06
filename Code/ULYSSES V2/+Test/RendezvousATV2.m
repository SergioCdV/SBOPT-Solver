%% ULYSSES %%
% Date: 01/06/25

%% Rendezvous ATV %% 
% This script provides a main interface to solve the ATV rendezvous mission via a pseudospectral method %

%% Set up
% close all
clear
rng(1)

load("ParametersATV.mat")

%% Problem definition
% Pre-amble
StateDimension = 4;             % Dimension of the state vector
ControlDimension = 2;           % Dimension of the control vector

% Problem parameters
Tmax = [1E-4];                  % Maximum acceleration

%% Numerical solver definition 
collocation = 'Chebyshev';      % Collocation method
m = 25;                         % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% ICs and transformation
% Adimensionalization
% Tmax = Tmax / Ac;

% YA transformation
tau = [nu_0 nu_f];                       % Initial and final anomalies
rho = 1 + Orbit_t(2) * cos(tau(1,:));    % Transformation
kp =    - Orbit_t(2) * sin(tau(1,:));    % Derivative of the transformation

L0 = [rho(1)   * eye(2) zeros(2); kp(1)   * eye(2) eye(2)/(rho(1)   * omega)];
Lf = [rho(end) * eye(2) zeros(2); kp(end) * eye(2) eye(2)/(rho(end) * omega)];

S0 = L0 * x0; 
SF = Lf * xf;

%% Optimization
J = zeros(1,length(Tmax));
Time = J; 
x = zeros(StateDimension * length(Tmax), m+1); 
u = zeros(ControlDimension * length(Tmax), m+1); 

for i = 1:length(Tmax)
    % Create the problem
    problem_params(1,1) = mu;           % Gravitational parameter
    problem_params(2,1) = h;            % Angular momentum
    problem_params(3,1) = Orbit_t(2);   % Eccentricity
    problem_params(4,1) = Tmax(i);      % Maximum thrust
    problem_params(5,1) = nu_0;         % Initial time
    problem_params(6,1) = nu_f;         % Final time
    problem_params(7,1) = Ac;           % Characteristic acceleration
    problem_params(8,1) = Lc;
    
    OptProblem = Problems.RendezvousATV(StateDimension, ControlDimension, problem_params, S0, SF);
    
    % Initial guess 
    X0 = repmat(SF, 1, m+1);
    Z0 = [reshape(X0, [], 1); zeros( (m + 1) * (ControlDimension), 1 ); 0; 1];
    
    % Solve the problem
    tic
    [x(1+StateDimension*(i-1):StateDimension*i,:), u(1+ControlDimension*(i-1):ControlDimension*i,:), J(i), tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
    Time(i) = toc; 
    
    % Transformation (YA)
    for j = 1:length(tau)
        rho = 1 + Orbit_t(2) * cos(tau(1,j));    % Transformation
        kp =    - Orbit_t(2) * sin(tau(1,j));    % Derivative of the transformation
        
        L = [rho * eye(2) zeros(2); kp * eye(2) eye(2)/(rho * omega)];
        
        x(1+StateDimension*(i-1):StateDimension*i,j) = L \ x(1+StateDimension*(i-1):StateDimension*i,j); 
    end

    % Dimensionalization 
    x(1+StateDimension*(i-1):StateDimension*i,:) = x(1+StateDimension*(i-1):StateDimension*i,:) .* repmat([Lc; Lc; Vc; Vc], 1, size(x,2));
    x(1+StateDimension*(i-1):StateDimension*i,:) = x(1+StateDimension*(i-1):StateDimension*i,:) / 1000; 
    u(1+ControlDimension*(i-1):ControlDimension*i,:) = u(1+ControlDimension*(i-1):ControlDimension*i,:) * Ac;
    J(i) = J(i) * Vc;
end

%% Plots
figure;
hold on
siz = repmat(100, 1, 1);
scatter(x(1,1), x(2,1), siz, 'b', 'Marker', 'square');
scatter(x(1,end), x(2,end), siz, 'b', 'Marker', 'o');
plot(x(1,:), x(2,:), 'c', 'LineWidth', 1)
xlabel('$x$ [km]')
ylabel('$z$ [km]')
legend('$\mathbf{s}_0$', '$\mathbf{s}_f$', '$a_{\mathrm{max}} = 10\,\mathrm{m/s}^2$', '$a_{\mathrm{max}} = 6.5\,\mathrm{cm/s}^2$');
hold on
grid on; 
xticklabels(strrep(xticklabels, '-', '$-$'));
yticklabels(strrep(yticklabels, '-', '$-$'));

save RendezvousATVSolution.mat -mat
