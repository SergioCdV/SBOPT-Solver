%% ULYSSES %%
% Date: 28/03/25

%% Pseudospectral optimization %%
% Generic solver for OCP via pseudospectral transcription

% Inputs: - class Problem, defining the problem of interest

% Outputs: - array x, the final state evolution matrix
%          - array u, a 3xm matrix with the control input evolution 
%          - scalar J, the final cost of the optimization 
%          - vector t, the time sampling points final distribution
%          - exitflag, the output state of the optimization process 
%          - structure output, containing information on the final state of
%            the optimization process

function [x, u, J, t, beta, exitflag, output] = solve(obj, Problem, Z0)
    % Last checks 
    if ( (obj.N + 1) * (Problem.StateDim + Problem.ControlDim) < Problem.StateDim * (obj.N + 1) )
        warning('The problem is over-constrained. Refining the grid...');
        obj.N = Problem.StateDim * (obj.N + 1) / (Problem.StateDim + Problem.ControlDim) - 1; 
    end
         
    % Quadrature definition
    Grid = obj.gridding(obj.N);
        
    % Objective function
    objective = @(Z)obj.cost_function(Problem, Grid, Z);

    % Non-linear constraints
    nonlcon = @(Z)obj.constraints(Problem, Grid, Z);

    % Upper and lower bounds 
    [P_lb, P_ub] = obj.opt_bounds(Problem);

    % Linear constraints
    [A, b, Aeq, beq] = Problem.LinConstraints( Problem.Params );

    % Modification of fmincon optimisation options and parameters (according to the details in the paper)
    options = optimoptions('fmincon', 'TolCon', 1e-3, 'Display', 'off', 'Algorithm', 'sqp', 'ScaleProblem', true);
    options.MaxFunctionEvaluations = obj.maxFunctionEvaluations;
    options.MaxIterations = obj.maxIter;
    
    % Optimisation
    [Z, J, exitflag, output] = fmincon(@(Z)objective(Z), Z0, A, b, Aeq, beq, P_lb, P_ub, @(Z)nonlcon(Z), options);
    
    % Solution 
    n = Problem.StateDim;                                               % State dimension
    m = Problem.ControlDim;                                             % Control dimension
    N = obj.N;                                                          % Order of the polynomial approximation
    StateCard = (N + 1) * n;                                            % Cardinality of the state
    ContrCard = (N + 1) * m;                                            % Cardinality of the state
    x = reshape( Z(1:StateCard), n, [] );                               % State vector
    u = reshape( Z(StateCard+1:StateCard + ContrCard), m, [] );         % Control vector
    t0 = Z(StateCard + ContrCard + 1);                                  % Initial value of the independent variable
    tf = Z(StateCard + ContrCard + 2);                                  % Final value of the independent variable
    beta = Z(StateCard+ContrCard+3:end);                                % Extra optimization parameters

    % Original time independent variable
    [t(1,:), t(2,:)] = Grid.Domain(t0, tf, Grid.tau);                        
    t = t(1,:);
    
    % Results 
    % obj.display_results(exitflag, cost, output);
end