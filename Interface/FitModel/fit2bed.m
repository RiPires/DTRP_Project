function result = fit2bed(BED,tau,v,T_day)
% function fit2bed
% HELP: this function returns the value of the survival rate for a given 
% value of BED for the second fitting function
% 
%
% INPUT
% * BED: Biologically Effective Dose (Gy)
% * tau: Elapsed time (months)
% * v: vector with fitting parameters
% * T_day - treatment time (days)
%
% OUTPUT
% * SR: Survival Rate (%)
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------

    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - alpha/beta Gy
    %v(5) - gamma days^-1
    %v(6) - Td days
    %v(7) - sigmak/K0
    %v(8) - delta


    denominator = v(7);
    p = v(2)*BED - ((v(5) * (tau - T_day)) ^ v(8));
    numerator = exp(-p) - v(1);
    t = numerator / denominator;
    if isreal(t)
        result = 100 * (1/2)*(1-erf(t/sqrt(2))); 
    else
        result = NaN;
    end
end