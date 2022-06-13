%% Project: 
% Date: 19/05/22

%% GA wrapper %%
% Function to compute the optimal basis and grid using metaheuristic GA and
% the associated optimal results

% Inputs: - structure system, containing the physical information of the
%           2BP of interest
%         - vector initial_coe, the initial orbital elements 
%         - vector final_coe, the final orbital elements 
%         - scalar K, an initial desired revolutions value 
%         - scalar T, the maximum allowed acceleration
%         - structure setup, containing the setup of the figures

% Outputs: - array C, the final state evolution matrix
%          - scalar dV, the final dV cost of the transfer 
%          - array u, a 3xm matrix with the control input evolution  
%          - scalar tf, the final time of flight 
%          - scalar tfapp, the initial estimated time of flight 
%          - vector tau, the time sampling points final distribution
%          - exitflag, the output state of the optimization process 
%          - structure output, containing information on the final state of
%            the optimization process

function [Sol] = ga_wrapper(system, initial_coe, final_coe, K, T, setup)
    % Genetic algorithm setup
    dof = 4;               % Number of DOF of the optimization process
    PopSize = 15;          % Population size for each generation
    MaxGenerations = 10;   % Maximum number of generations for the evolutionary algorithm
            
    options = optimoptions(@ga,'PopulationSize', PopSize, 'MaxGenerations', MaxGenerations);

    intcon = 1:dof;        % All DOF are integer

    A = []; 
    b = []; 
    Aeq = [];
    beq = [];
    nonlcon = [];

    % Lower and upper bounds 
    lb = [30 1 1 5];
    ub = [60 4 4 10];

    % Metaheuristic selection 
    [sol] = gamultiobj(@(x)gasp_opti(system, initial_coe, final_coe, K, T, x, setup), dof, A, b, Aeq, beq, lb, ub, nonlcon, intcon, options);

    % Final results 
    for i = 1:size(sol,1)
        m = sol(i,1);                         % Number of sampling points 
        sampling_distribution = sol(i,2);     % Final sampling distribution 
        switch (sampling_distribution)
            case 1
                sampling_distribution = 'Linear';
            case 2 
                sampling_distribution = 'Legendre';
            case 3 
                sampling_distribution = 'Chebyshev';
            case 4
                sampling_distribution = 'Regularized';
        end
    
        basis = sol(i,3);                     % Final sampling 
        switch (basis)
            case 1
                basis = 'Bernstein';
            case 2 
                basis = 'Orthogonal Bernstein';
            case 3
                basis = 'Legendre';
            case 4
                basis = 'Chebyshev';
        end
    
        n = sol(i,4);                         % Final approximation order
    
        Sol.Basis{i} = basis; 
        Sol.Order(i) = n; 
        Sol.Points{i} = sampling_distribution; 
        Sol.NumPoints(i) = m; 
    end
end
 

%% Auxiliary functions 
% Function to determine the best configuration 
function [cost] = gasp_opti(system, initial_coe, final_coe, K, T, x, setup)
    % Setup 
    m = x(1);                         % Number of sampling points 
    sampling_distribution = x(2);     % Final sampling distribution 
    switch (sampling_distribution)
        case 1
            sampling_distribution = 'Linear';
        case 2 
            sampling_distribution = 'Legendre';
        case 3 
            sampling_distribution = 'Chebyshev';
        case 4
            sampling_distribution = 'Regularized';
    end

    basis = x(3);                     % Final sampling distribution 
    switch (basis)
        case 1
            basis = 'Bernstein';
        case 2 
            basis = 'Orthogonal Bernstein';
        case 3
            basis = 'Legendre';
        case 4
            basis = 'Chebyshev';
    end
    n = x(4);                         % Final approximation order

    % Optimization
    [~, dV, ~, tf, ~, ~, exitflag, ~] = spaed_optimization(system, initial_coe, final_coe, K, T, m, sampling_distribution, basis, n, setup);

    % Final cost 
    cost = [dV tf/((exitflag == 1) || (exitflag == 2) || (exitflag == -3))];
end
