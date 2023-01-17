%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 31/01/22

%% Cost function %%
% Function to compute the cost function to be minimized

% Inputs: - string cost, the cost function to be minimized
%         - scalar mu, the gravitational parameter of the central body
%         - vector initial, the initial boundary conditions of the
%           trajectory
%         - vector final, the initial boundary conditions of the
%           trajectory
%         - matrix D, the differentiation matrix
%         - string basis, the polynomial basis to be used
%         - vector m, the number of nodes
%         - vector tau, the vector of collocation points
%         - vector W, the quadrature weights
%         - vector x, the degree of freedom to be optimized

% Outputs: - scalar r, the cost index to be optimized

function [r] = cost_function(cost, mu, initial, final, D, m, tau, W, x)
    % Optimization variables
    tf = x(end-1);              % Final time of flight
    
    switch (cost)
        case 'Minimum time'
            r = tf;             % Cost function
    
        case 'Minimum fuel'
            % Minimize the control input
            u = reshape(x(end-3*(m+1)-1:end-2), [3 length(tau)]);                     % Control points        
            a = sqrt(u(1,:).^2+u(2,:).^2+u(3,:).^2);                                  % Non-dimensional acceleration norm
    
            % Cost function
            if (isempty(W))
                r = tf*trapz(tau,a);
            elseif (length(W) ~= length(tau))
                r = 0; 
                for i = 1:floor(length(tau)/length(W))
                    r = r + tf/2*dot(W,a(1+length(W)*(i-1):length(W)*i));
                end
            else
                r = tf*dot(W,a);
            end
    
        otherwise
            error('No valid cost function was selected to be minimized');
    end
end
