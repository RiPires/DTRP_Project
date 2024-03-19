function result = secondfitting(tau,v,d,D,T_day,purpose)
% function secondfitting
% HELP: this function is the function of the second fit
%
% INPUT
% * tau: elapsed time (months)
% * v: vector with the parameters values
% * d - dose per fraction (Gy/fx)
% * D - prescription dose (Gy)
% * T_day - treatment time (days)
% * purpose: 'fitting' or 'plotting'
% 
%
% OUTPUT
% * fitting parameters (K, alpha, beta, gamma, a, Td, delta)
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------


%Function of the second fit
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
    denominator = v(5);
    p = v(2) * (1 + d / (v(2) / v(3))) * D - v(4) * T_day - ((v(4) * (30 * tau - T_day)) ^ v(6));
    % 30->to convert months into days
    numerator = exp(-p) - v(1);
    t = numerator / denominator;
    if strcmp(purpose, 'fitting')
    %during the fitting if t assumes complex values there is no issue
        result = 100 * (1/2)*(1-erf(t/sqrt(2)));
    elseif strcmp(purpose, 'plotting')
        if isreal(t)
            result = 100 * (1/2)*(1-erf(t/sqrt(2)));
        else
            result = NaN;
        end
    end
 end


