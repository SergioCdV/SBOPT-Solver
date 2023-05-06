%% SBOPT %%
% Date: 05/05/2023

%% Low-thurst MEE problem %% 
% Implementation of optimal low-thrust 3D orbital transfers in MEE coodinates

classdef LowThrustMEE < Problems.AbstractProblem 
    % Fundamental definition of the problem
    properties  
    end

    methods 
        % Constructor 
        function [obj] = LowThrustMEE(myInitial, myFinal, myDerDeg, myStateDim, myControlDim, myParams)
            super_arguments{1} = myInitial;
            super_arguments{2} = myFinal;
            super_arguments{3} = myDerDeg;
            super_arguments{4} = myStateDim;
            super_arguments{5} = myControlDim;

            if (exist('myParams', 'var'))
                super_arguments{6} = myParams;
            else
                super_arguments{6} = [];
            end

            obj@Problems.AbstractProblem(super_arguments{:});

            % Check the problem definition
            obj = obj.Check();
        end

        % Problem transcription
        [s0, sf] = BoundaryConditions(obj, initial, final, beta, t0, tf);
        [u] = ControlFunction(obj, params, beta, t0, tf, t, s);
        [M, L] = CostFunction(obj, params, beta, t0, tf, s, u);
        [A, b, Aeq, beq] = LinConstraints(obj, beta, P);
        [c, ceq] = NlinConstraints(obj, params, beta, t0, tf, tau, s, u);
        [beta, t0, tf] = InitialGuess(obj, params, initial, final);
        [LB, UB] = BoundsFunction(obj);

        function [obj] = Check(obj)
            obj = Check@Problems.AbstractProblem(obj);
        end
    end

    methods (Access = private)
        [S] = equinoctial2ECI(obj, mu, s, direction)
        [S] = coe2equinoctial(obj, s, direction);
        [tf] = initial_tof(obj, mu, T, initial, final);
        [B] = control_input(obj, mu, s);
    end
end