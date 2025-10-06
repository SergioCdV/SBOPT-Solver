%% ULYSSES %%
% Date: 07/02/2023

%% Cost function %% 
% Function implementation of the cost function 

function [M, L] = CostFunction(obj, params, beta, t, x, u)
    M = 0; 

    if ( params.Cost == 1 )
        L = sum( abs(u), 1 );
    else
        L = sqrt( dot(u, u, 1) );
    end
end