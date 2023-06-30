function result = fit1bed(BED,tau,v,T_month)
% function fit1bed
% HELP: this function returns the value of the survival rate for a given 
% value of BED for the first fitting function
% for a given value of BED and 
%
% INPUT
% * BED: Biologically Effective Dose (Gy)
% * tau: Elapsed time (months)
% * v: vector with fitting parameters
% * T_month - treatment time (months)
%
% OUTPUT
% * SR: Survival Rate (%)
%

    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - alpha/beta Gy
    %v(5) - gamma days^-1
    %v(6) - Td days
    %v(7) - a months^-1
    %v(8) - delta 

    p = v(2)*BED - ((v(7) * (tau - T_month)) ^ v(8));
    result = real(100*exp(-v(1)*exp(-p)));
end