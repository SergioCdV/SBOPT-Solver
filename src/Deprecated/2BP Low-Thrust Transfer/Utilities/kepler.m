%% Project: 
% Date: 01/04/22

%% Kepler %%
% This file contains the function to solve the time law of the Kepler problem

% Inputs: - vector elements, containing the mean classical Euler orbital elements (a, e, RAAN, i, omega, M). 

% Ouputs: - scalar theta, containing the true anomaly associated to the elements's mean anomaly.

function [theta] = kepler(elements)
    %Constants 
    e = elements(2);                                            %Eccentricity of the orbit
    M0 = elements(6);                                           %Mean anomaly of the orbit 
    
    %Set up the loop 
    k = 5;                                                      %Conway constant
    tol = 1e-15;                                                %Convergence tolerance
    iterMax = 10^6;                                             %Maximum number of iterations
    GoOn = true;                                                %Convergence flag
    iter = 1;                                                   %Initial iteration
    u = M0+e;                                                   %Conway method variable
    E(iter) = (M0*(1-sin(u))+u*sin(M0))/(1+sin(M0)-sin(u));     %Initial guess for the eccentric anomaly
    
    %Main computation 
    while ((GoOn) && (iter < iterMax))
        %Laguerre-Conway iterations
        f = E(iter)-e*sin(E(iter))-M0; 
        df = 1-e*cos(E(iter));
        ddf = e*sin(E(iter));
        dn = -k*(f)/(df+sqrt((k-1)^2*df^2-k*(k-1)*f*ddf));
        E(iter+1) = E(iter)+dn;
        
        %Convergence checking 
        if (abs(dn) < tol)
            GoOn = false;
        else
            iter = iter+1;
        end
    end  
    
    %True anomaly
    theta = atan2(sqrt(1-e^2)*sin(E(end))/(1-e*cos(E(end))), (cos(E(end))-e)/(1-e*cos(E(end))));
end