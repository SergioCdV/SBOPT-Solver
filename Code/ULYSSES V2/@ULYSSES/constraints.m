%% ULYSSES %%
% Date: 30/01/2022

%% Constraints %% 
% Function to compute the residual vector of the constraints of the problem

% Inputs: - class Problem, defining the problem at hands
%         - class Grid, the collocation grid used in the transcription
%           process
%         - vector Z, the decision variables to be optimized

% Outputs: - inequality constraint residual vector c
%          - equality constraint residual vector ceq

function [c, ceq] = constraints(obj, Problem, Grid, Z)
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
    beta = Z(StateCard+ContrCard+3:end);                                % Extra optimization parameters
    [t(1,:), t(2,:)] = Grid.Domain(t0, tf, Grid.tau);                   % Original time independent variable

    % Equalities 
    [c, ceq] = Problem.NlinConstraints(Problem.Params, beta, [t(1,:); Grid.W], X, U);    

    % Boundary conditions 
    if ( isempty(ceq) )
        ceq = Problem.BoundaryConditions(Problem.Params, beta, t(1,1), t(1,end), X);
    else
        ceq = [ceq; Problem.BoundaryConditions(Problem.Params, beta, t(1,1), t(1,end), X)];
    end

    % Dynamics 
    f = Problem.Dynamics(Problem.Params, beta, t, X, U);    % Vector field
    dx = zeros( size(f) );                                  % Pre-allocation of the dynamics residual

    % Differentiate the state 
    for i = 1:size(f,2) 
        dx(:,i) = sum( Grid.D(i,:) .* X, 2 );
    end

    % Compute the residual 
    res = dx - t(2,:) .* f;
    res = reshape( res, [], 1 );

    if ( isempty(ceq) )
        ceq = res;
    else
        ceq = [ceq; res];
    end
end