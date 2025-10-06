%% ULYSSES %%
% Date: 05/05/23

%% Chebyshev quadrature object %%
% Definition of the Chebyshev quadrature rule and collocation grid as an
% object

classdef ChebyshevGrid < CollocationMesh.AbstractGrid
    
    methods 
        % Constructor 
        function [obj] = ChebyshevGrid(m)
            if (exist('m', 'var'))
                obj.N = m;
            else
                obj.N = 100;
            end
 
            % Generation of the grid and grid rules
            [obj] = obj.CollocationGrid();           % Collocation grid
            [obj] = obj.QuadWeights();               % Quadrature weigths
            [obj] = obj.DiffMatrix();                % Differentiation matrix
            obj.J = 0.5;                             % Jacobian domain transformation 
        end

        % Particular methods
        function [obj] = CollocationGrid(obj)
            % Chebyshev nodes 
            i = obj.N:-1:0;
            obj.tau = cos(pi*i/obj.N);
        end

        function [obj] = DiffMatrix(obj)            
            % Main computation
            if (obj.N == 0) 
                obj.D = zeros(obj.N);

            else
                obj.D = zeros( obj.N + 1 );     % Pre-allocation 

                for k = 0:obj.N
                    ck = obj.coefficient( k );

                    for j = 0:obj.N
                        if ( k ~= j )
                            cj = obj.coefficient( j );
                            obj.D(k+1,j+1) = -(ck/cj) * (-1)^(j+k) / (obj.tau(j+1) - obj.tau(k+1));

                        elseif ( k == j && j == obj.N )
                            obj.D(k+1,j+1) = +(2 * obj.N^2 + 1) / 6;

                        elseif ( k == j && j == 0 )
                            obj.D(k+1,j+1) = -(2 * obj.N^2 + 1) / 6;
                        
                        else
                            obj.D(k+1,j+1) = -obj.tau(k+1) / (2 - 2 * obj.tau(k+1)^2);
                        end
                    end
                end
            end  
        end

        function [obj] = QuadWeights(obj)
            % Pre-allocation 
            obj.W = zeros(1, obj.N+1);
            N = obj.N;

            if ( mod(obj.N,2) == 0 )
                n = obj.N / 2;
                obj.W(1)   = 1 / (N^2-1);
                obj.W(end) = obj.W(1);
                j = 0:n;
                s = 1:n;
                c = [0.5 ones(1,length(j)-2) 0.5];
                obj.W(2:n+1) = 4 / N * sum( cos(2*pi*j.*s.'/N) ./ (1-4*j.^2) .* c, 2);
                obj.W(n+2:end-1) = flip( obj.W(2:n) );
            else
                n = (obj.N-1) / 2;
                obj.W(1)   = 1 / N^2;
                obj.W(end) = obj.W(1);
                j = 0:n;
                s = 1:n;
                c = [0.5 ones(1,length(j)-2) 0.5];
                obj.W(2:n+1) = 4 / N * sum( cos(2*pi*j.*s.'/N) ./ (1-4*j.^2) .* c, 2);
                obj.W(n+2:end-1) = flip( obj.W(2:n+1) );
            end
        end

        function [t, dt] = Domain(obj, t0, tf, tau)
            t  = (tf - t0) * obj.J * (1+tau) + t0; 
            dt = (tf - t0) * obj.J * ones(1,length(tau));
        end
    end   

    methods (Access = private)
        function [c] = coefficient(obj, k)
            idx_0 = k == 0 | k == obj.N; 
            c = ones(1,size(k,2));
            c(1,idx_0) = 2 * ones(1, sum(idx_0));
        end
    end
end