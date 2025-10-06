%% ULYSSES %%
% Date: 31/01/22

%% Cost function %%
% Function to compute the cost function to be minimized

% Inputs: - class Problem, defining the problem at hands
%         - class Grid, the collocation grid used in the transcription
%           process
%         - vector Z, the decision variables to be optimized

% Outputs: - scalar J, the cost index to be optimized

function [J] = cost_function(obj, Problem, Grid, Z)
    % Optimization variables
    n = Problem.StateDim;                                               % State dimension
    m = Problem.ControlDim;                                             % Control dimension
    N = obj.N;                                                          % Order of the polynomial approximation
    StateCard = (N + 1) * n;                                            % Cardinality of the state
    ContrCard = (N + 1) * m;                                            % Cardinality of the state
    X = reshape( Z(1:StateCard), n, [] );                               % State vector
    U = reshape( Z(StateCard+1:StateCard + ContrCard), m, [] );         % Control vector
    t0 = Z(StateCard + ContrCard + 1);                                  % Initial value of the independent variable
    tf = Z(StateCard + ContrCard + 2);                                  % Final value of the independent variable
    beta = Z(StateCard + ContrCard + 3:end);                            % Extra optimization parameters
    [t(1,:), t(2,:)] = Grid.Domain(t0, tf, Grid.tau);                   % Original time independent variable
        
    % Evaluate the cost function (Lagrange and Mayer terms)
    [M, L] = Problem.CostFunction(Problem.Params, beta, t(1,:), X, U); 

    if ( isempty(Grid.W) )
        J = M + trapz( t(2,:) .* Grid.tau, L );
    else
        J = M + dot( t(2,:) .* Grid.W, L );    
    end
end
