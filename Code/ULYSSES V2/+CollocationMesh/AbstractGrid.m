%% ULYSSES %%
% Date: 28/03/25

%% Grid %% 
% Implementation of the abstract mesh grid to be used in the collocation 

classdef (Abstract) AbstractGrid
    properties
        N;              % Number of points in the grid
        tau;            % Collocation grid
        W;              % Quadrature weights
        J;              % Domain transformation Jacobian
        D;              % Differentiation matrix
    end

    methods 
        % Class methods
        [obj] = CollocationGrid(m);
        [obj] = DiffMatrix(m);
        [obj] = QuadWeights(m);
        [t] = Domain(t0, tf, tau);
    end
end