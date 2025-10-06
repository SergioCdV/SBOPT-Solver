%% ULYSSES %%
% Date: 07/02/2023

%% Dynamics %% 
% Function implementation of the dynamics vector field

function [f] = Dynamics(obj, params, beta, t, x, u)
    % Constants and parameters
    A = [zeros( size(x,1)/2 ) eye( size(x,1)/2 ); zeros( size(x,1)/2 ) zeros( size(x,1)/2 )];       % State matrix
    B = [zeros(size(A,1)/2,size(u,1)); eye(size(A,1)/2,size(u,1))];                                 % Control input matrix

    % Vector field 
    f = A * x + B * u;                      % LQR vector field
end