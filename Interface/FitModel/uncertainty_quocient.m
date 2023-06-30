% function uncertainty_quocient
% HELP: this function returns the uncertainty of a quocient 
% of two parameters (used for the uncertainties of Td and 𝜶/𝜷)
%
% INPUT
% * a: parameter of the numerator
% * b: parameter of the denominator
% * un_a: uncertainty of the parameter of the numerator
% * un_b: uncertainty of the parameter of the denominator
%
% OUTPUT
% * uncertainty of a quocient of two parameters a, and b (uq)
%
%

function uq = uncertainty_quocient(a,b,un_a,un_b)
    uq = sqrt( (1/b^2)*(un_a)^2 + ((-a/b^2)^2)*((un_b)^2) );
end