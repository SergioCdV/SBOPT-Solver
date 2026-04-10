%% Project: Shape-based optimization for low-thrust transfers %%
% Date: 07/02/2023

%% Control function %% 
% Function implementation of the control function as a dynamics residual

function [u] = ControlFunction(obj, params, beta, t0, tf, t, s)
    % Compute the acceleration field
    r  = params(2) + s(1,:);
    vt = s(5,:) .* r;
    
    radial     = s(7,:) - ( vt.^2 ./ r - params(1) ./ r.^2 );
    tangential = ( r.* s(8,:) + s(4,:) .* s(5,:) ) - ( - vt .* s(4,:) ./ r );

    gamma     = atan2( tangential, radial );
    cos_gamma = cos(gamma); 
    sin_gamma = sin(gamma);

    % Compute the control vector as a dynamics residual
    u = -s(6,:) .* params(4) * params(5) .* [cos_gamma; sin_gamma];
end