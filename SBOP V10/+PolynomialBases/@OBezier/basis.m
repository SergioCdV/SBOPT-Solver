%% Project: 
% Date: 29/01/2022

%% Orthogonal Bernstein polynomials
% This function uses the direct definition of orthogonal Bernstein polynomials

% Inputs: - scalar degree, the number of polynomials in the basis
%         - vector tvec, the control parameter t vector 

% Output: - Phi, an array of Bernstein polynomials in the form length(tvec) 
%           degree x length(tvec)

function [Phi] = basis(obj, order, u)    
    % Find number of steps (time increments)
    steps = length(u);
    
    % Initialize variable for n-order curve
    Phi = zeros(order+1,steps); 
    
    % Calculation of the orthogonal Bernstein polynomials 
    for i = 0:order
        % Indexing parameter
        k = i+1;

        for j = 0:i 
            % Compute the non-orthonomal basis 
            B = PolynomialBases.Bezier().basis(order-j, u);

            % Compute the scaling 
            num = nchoosek(2*order+1-j,i-j) * nchoosek(i,j);
            den = nchoosek(order-j,i-j);
            K = num/den; 

            % Compute the orthonomal basis
            Phi(k,:) = Phi(k,:) + (-1)^j * K * B(i-j+1,:);
        end

        % Final scaling
        Phi(k,:) = sqrt(2*(order-i)+1)*Phi(k,:);
    end
end