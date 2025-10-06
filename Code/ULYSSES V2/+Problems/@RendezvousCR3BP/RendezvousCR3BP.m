%% ULYSSES %%
% Date: 06/10/2025

%% Rendezvous in the CR3BP %% 
% This script provides a main interface to solve a linearized rendezvous problem in the CR3BP via a pseudospectral method %

classdef RendezvousCR3BP < Problems.AbstractOCP
    % Fundamental definition of the problem
    properties  
    end

    methods 
        % Constructor 
        function [obj] = RendezvousCR3BP(myStateDim, myControlDim, myParams, myInitial, myFinal)
            super_arguments{1} = myStateDim;
            super_arguments{2} = myControlDim;
            super_arguments{4} = myInitial;
            super_arguments{5} = myFinal;

            if (exist('myParams', 'var'))
                super_arguments{3} = myParams;
            else
                super_arguments{3} = [];
            end

            obj@Problems.AbstractOCP( super_arguments{:} );

            % Check the problem definition
            obj = obj.Check();
        end

        % Problem transcription
        [x0, xf] = BoundaryConditions(obj, X0, XF, beta, t0, tf);
        [res] = Dynamics(obj, params, beta, t, x, u);
        [M, L] = CostFunction(obj, params, beta, t, x, u);
        [A, b, Aeq, beq] = LinConstraints(obj, params);
        [c, ceq] = NlinConstraints(obj, params, beta, t, x, u);
        [LB, UB] = BoundsFunction(obj);
    end
end