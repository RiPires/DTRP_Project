function e = eqdxfunction(d,alpha_beta,D,X)
% function eqdxfunction
% HELP: this function returns the value of the eqdx function 
%
% INPUT
% * d - dose per fraction (Gy/fx)
% * alpha_beta - quocient between alpha and beta (fitting parameters)
% * D - prescription dose (Gy)
% * X - fractions for the Equivalent Dose (Gy)
%
%
% OUTPUT
% * EQDX value
% -------------------------------------------------------------------------
% made by A. Pardal in 04/09/2023
% -------------------------------------------------------------------------


    e = D*((d + alpha_beta)/(X + alpha_beta));

end
