function result = fit1eqdx(EQDX,tau,v,T_month,X)
% function fit1eqdx
% HELP: this function returns the value of the survival rate for a given 
% value of EQDX for the first fitting function
% 
%
% INPUT
% * EQDX: Equivalent Dose in XGy fractions (Gy)
% * tau: Elapsed time (months)
% * v: vector with fitting parameters
% * T_month - treatment time (months)
% * X: fractions of the EQDX (Gy)
%
% OUTPUT
% * SR: Survival Rate (%)
% -------------------------------------------------------------------------
% made by A. Pardal in 17/03/2024
% -------------------------------------------------------------------------

    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - alpha/beta Gy
    %v(5) - gamma days^-1
    %v(6) - Td days
    %v(7) - a months^-1
    %v(8) - delta 

    p = (v(2)*EQDX*(1+(X/v(4)))) - (v(5)*T_month) - ((v(7) * (tau - T_month)) ^ v(8));
    result = real(100*exp(-v(1)*exp(-p)));
end
