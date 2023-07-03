function [param,new_param,chi2_val] = perform_fit2(files,N,d,D,T_day,T_month, initial_guess,lower_bound,upper_bound,fitting_function,purpose,fnumber)
% function perform_fit2
% HELP: this function performs the second fit and returns the fitting parameters 
% and the value of the chi-square function
%
% INPUT
% * files: data files
% * N: number of patients
% * d: dose per fraction (Gy/fx)
% * D: prescription dose (Gy)
% * T_day: treatment time (days)
% * initial_guess: vector with the initial guess of the parameters
% * lower_bound: vector with the lower bound values of the parameters
% * upper_bound: vector with the upper bound values of the parameters
% * fitting_function: second fitting function
% * purpose: 'fitting' if we are performing a fit for the given datafiles or 
%'bootstrapping' if we are performing a fit for the generated points with
% bootstrapping
%
% OUTPUT
% * fitting parameters (param): K50/K0,alpha,beta,gamma,sigmak/K0,delta 
% * fitting parameters (new_param): K50/K0,alpha,alpha/beta,Td,sigmak/K0,delta 
% * value of the chi square function (chi2_val)
%
%
    % Vector with fitting parameters -> v
    % Chi-square function
    chi2 = @(v) chi2_residuals(files, N, d, D, T_day, T_month, v, fitting_function, purpose, fnumber);

    % Set up the algorithm options
    options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);
    % Run the algorithm
        % param->parameters that minimize the chi-square function
        % chi2_val->value of the chi-square function
    [param,chi2_val] = fmincon(chi2, initial_guess, [], [], [], [], lower_bound, upper_bound, [], options);
    % new list of parameters, where two of them were changed:
    % beta -> alpha/beta
    % gamma -> Td
    new_param = param;
    alpha_beta = new_param(2)/new_param(3);
    new_param(3) = alpha_beta;
    Td = log(2)/new_param(4);
    new_param(4) = Td;
    % new param entries:
        %param(1) - K50/K0 
        %param(2) - alpha Gy^-1
        %param(3) - alpha/beta Gy
        %param(4) - Td days
        %param(5) - sigmak/K0
        %param(6) - delta 
end