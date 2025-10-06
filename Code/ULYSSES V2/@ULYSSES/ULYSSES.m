%% ULYSSES %%
% Date: 28/03/2025

%% ULYSSES solver %% 
% Abstract implementation of the pseudospectral solver %  

classdef ULYSSES
    properties 
        % Numerical solver configuration
        N;                                  % Number of nodes in the independent variable grid
        Mesh;                               % Define the independent variable grid to be used

        % Initial guess 
        InitialGuessFlag = false;           % Flag to indicate an initial guess is supplied
        Z0;                                 % Parameters initial guess

        % Optimization configuration 
        maxIter = 1e4;
        maxFunctionEvaluations = 1e6;
    end

    methods 
        % Solver definition 
        function [obj] = ULYSSES(myCollocation, myN)
            % Solver definition            
            if (exist('myCollocation', 'var'))
                obj.Mesh = myCollocation;
            else
                obj.Mesh = 'Legendre';
            end
    
            if (exist('myN', 'var'))
                obj.N = myN;
            else
                obj.N = 100;
            end

            % Checks and environment settings
            obj.set_graphics();
        end

        % Solve
        [C, cost, u, t0, tf, t, exitflag, output, P] = solve(obj, Problem, Z0);
        [B, C, tau] = state_basis(obj, L, n, basis, tau);
        [Grid] = gridding(obj,m);
        [C] = evaluate_state(obj, P, B, n, L);
    end

    methods (Access = private)        
        [P_lb, P_ub] = opt_bounds(obj, Problem, n, B);
        [P] = boundary_conditions(obj, Problem, beta, t0, tf, tau, B, basis, n, P0);
        [c, ceq] = constraints(obj, Problem, Mesh, Z);
        [r] = cost_function(obj, Problem, Mesh, Z);
    end

    methods (Static, Access = private)
        % Set graphics
        function set_graphics()
            % Set graphical properties
            set(groot, 'defaultAxesTickLabelInterpreter', 'latex'); 
            set(groot, 'defaultAxesFontSize', 11); 
            set(groot, 'defaultAxesGridAlpha', 0.3); 
            set(groot, 'defaultAxesLineWidth', 0.75);
            set(groot, 'defaultAxesXMinorTick', 'on');
            set(groot, 'defaultAxesYMinorTick', 'on');
            set(groot, 'defaultFigureRenderer', 'painters');
            set(groot, 'defaultLegendBox', 'off');
            set(groot, 'defaultLegendInterpreter', 'latex');
            set(groot, 'defaultLegendLocation', 'best');
            set(groot, 'defaultLineLineWidth', 1); 
            set(groot, 'defaultLineMarkerSize', 3);
            set(groot, 'defaultTextInterpreter','latex');
        end

        display_results(exitflag, cost, output);
    end
end