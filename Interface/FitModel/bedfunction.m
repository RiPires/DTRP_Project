function b = bedfunction(d,alpha,alpha_beta,D,gamma,T)
% function bedfunction
% HELP: this function returns the value of the bed function 
%
% INPUT
% * d - dose per fraction (Gy/fx)
% * alpha - fitting parameter
% * alpha_beta - quocient between alpha and beta (fitting parameters)
% * D - prescription dose (Gy)
% * gamma - fitting parameter 
% * T_day - treatment time (days)
%
%
% OUTPUT
% * BED value
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------

    b = (1+(d/alpha_beta))*D - (gamma*T)/alpha;

end
