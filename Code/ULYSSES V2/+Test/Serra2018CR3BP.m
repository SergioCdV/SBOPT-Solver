%% ULYSSES %%
% Date: 06/10/25

%% Rendezvous in the CR3BP %% 
% This script provides a main interface to solve a linearized rendezvous problem in the CR3BP via a pseudospectral method %

%% Set up
close all
clear
rng(1)

%% Problem definition
% Pre-amble
StateDimension = 6;             % Dimension of the state vector
ControlDimension = 3;           % Dimension of the control vector

% Problem parameters
Lc = 384399e3;                  % Characteristic length
Tc = 2.361e6;                   % Characteristic time
Vc = Lc / Tc * 2*pi;            % Characteristic velocity 
mu = 0.0121505856;              % Gravitational parameter of the system
c2 = 3.190425213622208;         % Richardson constant

Omega = 2 * [0 1 0; -1 0 0; 0 0 0];             % Coriolis term
H = [1+2*c2 0 0; 0 1-c2 0; 0 0 -c2];            % Hessian of the Hamiltonian
A = [zeros(3) eye(3); H Omega];                 % State space matrix

%% Numerical solver definition 
collocation = 'Chebyshev';       % Collocation method
m = 20;                          % Number of collocation points
 
% Create the solver
solver = ULYSSES(collocation, m);

%% Optimization
% Create the problem
problem_params.A = A;                       % Specific impulse
problem_params.B = [zeros(3); eye(3)];      % Control input matrix
problem_params.T0 = 3.322;                  % Initial time
problem_params.TF = 4.737;                  % Final time
problem_params.Cost = 2;                    % L1 or L2 cost

% Initial conditions
S0 = [6449.40 65117.03 22814.91 -0.0312 0.0392 0.2114];   

% Final conditions
SF = [59066.09 67728.64 84015.47 -0.1087 0.1616 -0.1730];

S0 = S0 ./ [Lc Lc Lc Vc Vc Vc];
SF = SF ./ [Lc Lc Lc Vc Vc Vc];

OptProblem = Problems.RendezvousCR3BP(StateDimension, ControlDimension, problem_params, S0.', SF.');

% Initial guess 
X0 = repmat(SF, 1, m+1);
Z0 = [reshape(X0, [], 1); zeros( (m + 1) * (ControlDimension), 1 ); 0; 1];

% Solve the problem
tic
[s, u, J, tau, beta, exitflag, output] = solver.solve(OptProblem, Z0);
toc 

%% Results 
dV = u;

switch ( problem_params.Cost )
    case 1
        dV_norm(1,:) = sum( abs(dV(1:3,:) ), 1);

    case 2
        dV_norm(1,:) = sqrt( dot(dV(1:3,:), dV(1:3,:), 1) );

    case 3
        dV_norm(1,:) = max( abs( dV(1:3,:) ) );
end

% Impulsive times 
ti(1,:) = dV_norm(1,:) ~= 0;
cost(1) = sum( dV_norm(1,ti(1,:)), 2) * Vc;

% Re-dimensionalization
s = s .* repmat( [Lc Lc Lc Vc Vc Vc].', 1, size(s,2)) / 1000; 

%% Save results 
save ResultsSerraL2PS

%% Plots
% figure;
% hold on
% plot(tau, u, 'LineWidth', 0.3)
% xlabel('$t$ [-]')
% ylabel('$\mathbf{u}$')
% grid on;
% xticklabels(strrep(xticklabels, '-', '$-$'));
% yticklabels(strrep(yticklabels, '-', '$-$'));

figure
hold on
stem(tau, dV_norm(1,:) * Vc, 'filled', 'r'); 
grid on;
ylabel('$\|\Delta \mathbf{V}\|_p$ [m/s]')
xlabel('$t$')
% xticklabels(strrep(xticklabels, '-', '$-$'));
% yticklabels(strrep(yticklabels, '-', '$-$'));
xlim([tau(1) tau(end)])

siz = repmat(100, 1, 1);
figure 
view(3)
hold on
scatter3(s(1,1), s(2,1), s(3,1), siz, 'b', 'Marker', 'square');
scatter3(s(1,end), s(2,end), s(3,end), siz, 'b', 'Marker', 'o');

% Plot each trajectory and the corresponding control law
siz2 = repmat(100, sum(ti(1,:)), 1);
state_idx = [1 2 3];
impulses = ti(1,:);

scatter3( s(1,impulses), s(2,impulses), s(3,impulses), siz2, 'Marker', 'x' );
plot3( s(1,:), s(2,:), s(3,:) ); 

legend('$\mathbf{s}_0$', '$\mathbf{s}_f$', '$\Delta \mathbf{V}_i$', 'AutoUpdate', 'off');

hold off
grid on;
xlabel('$x$ [km]')
ylabel('$y$ [km]')
zlabel('$z$ [km]')
% xticklabels(strrep(xticklabels, '-', '$-$'));
% yticklabels(strrep(yticklabels, '-', '$-$'));
% zticklabels(strrep(zticklabels, '-', '$-$'));

