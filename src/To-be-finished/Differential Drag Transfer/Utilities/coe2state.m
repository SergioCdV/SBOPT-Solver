%% Project: 
% Date: 01/04/22

%% Classical orbital elements to state vector %%
% This file contains the function to change from classical orbital elements to state vector

% Inputs: - scalar mu, the gravitational parameter of the central voyd.
%         - vector elements, containing the classical orbital elements. 

% Ouputs: - vector s, containing the state vector in the inertial frame (position and velocity vectors).

function [s] = coe2state(mu, elements)
    %Constants 
    e = elements(2);                                            %Eccentricity of the orbit
    
    %Singularity warnings 
    tol = 1e-10;                                                %Circular orbit tolerance    
    if (abs(norm(e)) < tol)
        elements(5) = 0;
    end
    
    if (elements(4) == 0)
        elements(3) = 0;
    end
    
    %Compute the semilatus rectum
    if (elements(1) == Inf) 
        p = elements(end);                                      %Semilatus rectum of the orbit
    else
        p = elements(1)*(1-elements(2)^2);                      %Semilatus rectum of the orbit
    end
    
    %Compute the angular momentum norm
    h = sqrt(mu*p);                                             %Angular momentum of the orbit
    
    %Compute the mean anomaly
    theta = kepler(elements);                                   %True anomaly in the orbit
    
    %Compute the perifocal state vector
    r = (p/(1+e*cos(theta)))*[cos(theta); sin(theta); 0];       %Position vector in the perifocal frame
    v = mu/h*[-sin(theta); e+cos(theta); 0];                    %Velocity vector in the perifocal frame
    
    %Rotation matrix from the inertial to the perifocal frame
    Q = euler_matrix(elements);
       
    %Output
    r = Q.'*r;      %Position vector in the inertial frame
    v = Q.'*v;      %Velocity vector in the inertial frame
    s = [r; v];     %State vector
end