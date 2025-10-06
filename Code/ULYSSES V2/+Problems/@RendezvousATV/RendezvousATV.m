%% ULYSSES %%
% Date: 01/06/2025

%% ATV rendezvous %% 
% Implementation of a low-thrust transfer linear rendezvous via pseudospectral transcription %

classdef RendezvousATV < Problems.AbstractOCP
    % Fundamental definition of the problem
    properties  
    end

    methods 
        % Constructor 
        function [obj] = RendezvousATV(myStateDim, myControlDim, myParams, myInitial, myFinal)
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