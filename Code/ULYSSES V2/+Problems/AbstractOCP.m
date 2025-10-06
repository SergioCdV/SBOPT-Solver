%% ULYSSES %%
% Date: 28/03/2025

%% Optimal Control Problem %% 
% Abstract implementation of an OCP %  

classdef (Abstract) AbstractOCP
    % Fundamental definition of the problem
    properties  
        % State dynamics
        X0;             % Initial boundary conditions 
        XF;             % Final boundary conditions              
        StateDim;       % State dimension 
        ControlDim;     % Control dimension

        % General parameters 
        Params;         % General parameters
    end

    methods 
        function [obj] = AbstractOCP(myStateDim, myControlDim, myParams, myInitial, myFinal)           
            obj.StateDim = myStateDim;              % State dimension 
            obj.ControlDim = myControlDim;          % Control dimension
            obj.Params = myParams;                  % Problem parameters
            obj.X0 = myInitial;                     % Initial boundary conditions 
            obj.XF = myFinal;                       % Final boundary conditions 
        end

        % Problem transcription
        [res] = BoundaryConditions(obj, X0, XF, beta, t, x);
        [res] = Dynamics(obj, params, beta, t, x, u);
        [M, L] = CostFunction(obj, params, beta, t, x, u);
        [A, b, Aeq, beq] = LinConstraints(obj, params);
        [c, ceq] = NlinConstraints(obj, params, beta, t, x, u);
        [LB, UB] = BoundsFunction(obj);
        
        function [obj] = Check(obj)
            % Check the dimensionality of the dynamics 
%             if ( size(obj.X0,1) ~= obj.StateDim || size(obj.XF,1) ~= obj.StateDim ) 
%                 error('Supplied boundary conditions are not of appropriate dimensions... Aborting');
%             end
        end
    end
end