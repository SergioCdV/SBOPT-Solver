%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 30/01/2022

%% Constraints %% 
% Function to compute the residual vector of the constraints of the problem

% Inputs: - scalar mu, the gravitational parameter of the central body 
%         - scalar T, the maximum acceleration allowed for the spacecraft
%         - vector initial, the initial boundary conditions of the
%           trajectory 
%         - vector final, the initial boundary conditions of the
%           trajectory
%         - vector n, the vector of degrees of approximation of the state
%           variables
%         - vector x, the degree of freedom to be optimized 
%         - cell array B, the polynomial basis to be used
%         - string basis, the polynomial basis to be used
%         - string dynamics, the independent variable parametrization to be
%           used
%         - string cost, the cost function to be minimized

% Outputs: - inequality constraint residual vector c
%          - equality constraint residual vector ceq

function [c, ceq] = constraints(mu, initial, final, tf, time_free, B, basis, n, tau, x)
    % Extract the optimization variables
    P = reshape(x(1:end-3), [length(n), max(n)+1]);     % Control points
    thetaf = x(end-2);                                  % Final fiber parameter
    sf = x(end-1);                                      % Final time of flight 
    T = x(end);                                         % Needed thrust vector

    R = [cos(thetaf) 0 0 -sin(thetaf); 0 cos(thetaf) sin(thetaf) 0; 0 -sin(thetaf) cos(thetaf) 0; sin(thetaf) 0 0 cos(thetaf)];
    final = final*blkdiag(R,R).';

    % Boundary conditions points
    P = boundary_conditions(sf, n, initial, final, P, B, basis);

    % Trajectory evolution
    C = evaluate_state(P,B,n);

    % Sundman transformation
    r = dot(C(1:4,:),C(1:4,:),1);

    % Control input 
    [u, ~] = acceleration_control(mu, C, sf);

    % Equalities 
    res = C(1,:).*C(9,:)-C(2,:).*C(8,:)+C(3,:).*C(7,:)-C(4,:).*C(6,:);
    ceq = [u(4,:) res];

    if (time_free)
        ceq = [ceq tf-sf*trapz(tau, r)];
    end

    % Inequalities
    U = u(1:3,:);
%     for i = 1:size(C,2)
%         aux = KS_matrix(C(1:4,:)).'\u(:,i);
%         U(:,i) = aux(1:3);
%     end
    c = [dot(U,U,1)-(sf^2*repmat(T,1,size(u,2))).^2];
end