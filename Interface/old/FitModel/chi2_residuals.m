function r = chi2_residuals(files, N_list, d_list, D_list, T_day_list, T_month_list, v, f,purpose,fnumber)
% function perform_fit2
% HELP: this function calculates the residuals of the points of the input datafile(s)
% to obtain the value of the chi-square function
%
% INPUT
% * files: data files
% * N_list: list with the number of patients for the selected file(s)
% * d_list: list with the dose per fraction (Gy/fx) values for the selected file(s) 
% * D_list: list with the prescription dose (Gy) values for the selected file(s) 
% * T_day_list: list with the treatment time (days) values for the selected file(s) 
% * T_month_list: list with the treatment time (months) values for the selected file(s) 
% * v: vector with the parameters values
% * f: fitting function
% * purpose: 'fitting' if we are performing a fit for the given datafiles or 
%'bootstrapping' if we are performing a fit for the generated points with
% bootstrapping
% * fnumber: number of the fit (1 or 2)
%
% OUTPUT
% * fitting chi2 residuals (r): residuals of the chi2 function
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------

    s = 0; %sum for all the points of all the files
    for i = 1:length(files)
        if strcmp(purpose, 'fitting')
            data = load(files{i});
        elseif strcmp(purpose, 'bootstrapping')
            data = files{i};
        end
        x = data(:, 1); %x (tau) - elapsed time in months
        y = data(:, 2); %y (SR) - survival rate in percentage
        N = N_list(i);
        d = d_list(i);
        D = D_list(i);
        T_day = T_day_list(i);
        T_month = T_month_list(i);
        sf = 0; %sum for the points of a specific file

        for j = 1:length(x)
            if fnumber == 1 % fit 1
                y_fit = f(x(j),v,d,D,T_day,T_month);
            elseif fnumber == 2 % fit 2
                y_fit = f(x(j),v,d,D,T_day);
            end
            
            sigma = y(j) .* sqrt(abs((1-y(j)))./N);
            res = (y_fit - y(j)).^2 / sigma.^2;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = s;
end