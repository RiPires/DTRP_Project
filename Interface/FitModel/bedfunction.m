function b = bedfunction(d,alpha,alpha_beta,D,gamma,T)
% function bedfunction
% HELP: this function returns the value of the bed function 
%
% INPUT
% * d - dose per fraction (Gy/fx)
% * alpha - fitting parameter
% * beta - fitting parameter
% * D - prescription dose (Gy)
% * gamma - fitting parameter 
% * T_day - treatment time (days)
%
%
% OUTPUT
% * BED value

    b = (1+(d/alpha_beta))*D - (gamma*T)/alpha;

end
