%% ULYSSES %%
% Date: 28/03/2025

%% Grid %% 
% Function to compute a desired polynomail collocation grid

% Inputs: - scalar m, the number of points in the grid

% Outputs: - object Grid, defining the collocation grid and associated quadrature rule

function [Grid] = gridding(obj, m)
    
    if (~exist('m', 'var'))
        m = obj.N;
    end

    % Final sampling distribution setup
    switch (obj.Mesh)
        
        case 'Chebyshev'
            Grid = CollocationMesh.ChebyshevGrid(m);

        otherwise
            error('No valid quadrature was selected. Aborting...');
    end
end