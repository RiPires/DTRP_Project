clc, clearvars %clear

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL
file_names = {'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
number_studies = numel(file_names);
% Data from the files:
%x (tau) - elapsed time in months
%y (SR) - survival rate in percentage
N_values = [128, 35, 83, 51, 24]; %N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]; %T_day - treatment time in days
T_month_values = zeros(size(T_day_values)); %T_month  - treatment time in months
for i = 1:length(T_day_values)
    tm = T_day_values(i)/30;
    T_month_values(i) = tm;
end
n_param = 6; %n_param - number of fitting parameters
n_points = 0; %n_points - number of points from all the files
for i = 1:length(file_names)
    file = load(file_names{i});
    s = size(file);
    n_points = n_points + s(1);
end

%v - vector with parameters to find   
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

% Initial parameter values - defined by the user
v0 = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];

% Define the parameter bounds
lb = [0, 0, 0, 0, 1000, 0];
ub = [0.05, 0.05, 0.003, 0.007, 1500, 0.30];

% Define the fitting function
f = @(x,v,d,D,T_day,T_month) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_month)).^v(6)))));

% Perform the fit 
    % v_min_old: vector with parameters of the fitting function 
    % where we have beta instead of alpha/beta and gamma instead of Td
    % v_min: vector with parameters of the fitting function
    % fval: value of the chi-square function

[v_min_old,v_min,fval] = perform_fit(file_names,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'fitting');

%v_min - vector with found parameters 
    %v_min(1) - K 
    %v_min(2) - alpha Gy^-1
    %v_min(3) - alpha/beta Gy
    %v_min(4) - Td days
    %v_min(5) - a months^-1
    %v_min(6) - delta 

% Goodness of the fit
% dof - degrees of freedom
dof = n_points-n_param;
goodfit = fval/dof;

% CIs (confidence intervals) calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstraping 
fit_replicates = []; % array to store the replicas of the fitting parameters
n = 1000; % number of replicates -> we will get 1000 new values for the fitting parameters
for i = 1:n 
    % cell array to store the samples for each replicate
    generated_files = cell(1, number_studies);
    for j = 1:number_studies
        % generating a sample for each file
        data_study=load(file_names{j});
        generated_files{j} = sample(data_study);
    end

    % perform the fit for each replica
        % v_min_boot_old: vector with parameters of the fitting function 
        % where we have beta instead of alpha/beta and gamma instead of Td
        % v_min_boot: parameters of the fitting function for that replica
        % fval_boot: value of the chi-square function

    [v_min_boot_old,v_min_boot,fval_boot] = perform_fit(generated_files,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'bootstrapping');
   
    fit_replicates = vertcat(fit_replicates, v_min_boot);
end


% Uncertainties given by the Bootstrapping
u_boot_plus = zeros(n_param); % array to store the upper uncertainty of the fitting parameters
u_boot_minus = zeros(n_param); % array to store the lower uncertainty of the fitting parameters
CI_u = zeros(n_param); % array to store the upper value of the confidence intervals of the fitting parameters
CI_l = zeros(n_param); % array to store the lower value of the confidence intervals of the fitting parameters

for i = 1:n_param
    CI = ci_boot(fit_replicates(:,i)); % confidence interval
    CI_u(i) = CI(2);
    CI_l(i) = CI(1);
    [u_plus,u_minus] = uncertainties(v_min(i),CI);
    u_boot_plus(i) = u_plus;
    u_boot_minus(i) = u_minus;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profile-Likelihood


% Uncertainties given by the Profile-Likelihood
% u_boot_plus = zeros(n_param); % array to store the upper uncertainty of the fitting parameters
% u_boot_minus = zeros(n_param); % array to store the lower uncertainty of the fitting parameters
% for i = 1:n_param
%     CI = ci_boot(fit_replicates(:,i),v_min(i)); % confidence interval
%     [u_plus,u_minus] = uncertainties(v_min(i),CI);
%     u_boot_plus(i) = u_plus;
%     u_boot_minus(i) = u_minus;
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters_names = {'K','alpha','alpha/beta','Td','a','delta'};

% Save the results in a file
myfile = fopen('./results/fit1.txt', 'w');  

fprintf(myfile, 'Goodness of the fit: %f\n', goodfit);
fprintf(myfile, '\n');
fprintf(myfile, 'Uncertainties given by the Bootstrapping Method:\n');
fprintf(myfile, 'Parameters values that minimize the sum of squares: value [- uncertainty + uncertainty]:\n');
fprintf(myfile, '-----------------\n');
formatSpec = '%s: %.6f [-%.6f + %.6f]\n CI: [%.6f,%.6f]\n';
for i = 1:length(parameters_names)
    fprintf(myfile, formatSpec, parameters_names{i}, v_min(i), u_boot_minus(i), u_boot_plus(i),CI_l(i),CI_u(i));
end
fprintf(myfile, '\n');
fprintf(myfile, 'Uncertainties given by the Profile-Likelihood Method:\n');
fprintf(myfile, '-----------------\n');
fprintf(myfile, 'Parameters values that minimize the sum of squares: value [- uncertainty + uncertainty]:\n');


% Close the file
fclose(myfile);


% Plotting
hold on
x_points = linspace(0, 70, 71);
% Liang
data = load(file_names{1});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 6, 'DisplayName', 'Liang')
%fitted function   
plot(x_points, f(x_points,v_min_old,d_values(1),D_values(1),T_day_values(1),T_month_values(1)), '--', 'LineWidth', 2, 'Color', '#FD04FC','HandleVisibility', 'off')

% Dawson
data = load(file_names{2});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 6, 'DisplayName', 'Dawson');
%fitted function
plot(x_points, f(x_points,v_min_old,d_values(2),D_values(2),T_day_values(2),T_month_values(2)), '--', 'LineWidth', 2, 'Color', '#0000F7','HandleVisibility', 'off');

% SeongH
data = load(file_names{3});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, '^', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 6, 'DisplayName', 'SeongH')
%fitted function
plot(x_points, f(x_points,v_min_old,d_values(3),D_values(3),T_day_values(3),T_month_values(3)), '--', 'LineWidth', 2, 'Color', '#000000','HandleVisibility', 'off')

% SeongM
data = load(file_names{4});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FD6C6D','MarkerSize', 6, 'DisplayName', 'SeongM')
%fitted function
plot(x_points, f(x_points,v_min_old,d_values(4),D_values(4),T_day_values(4),T_month_values(4)), '--', 'LineWidth', 2, 'Color', '#FD6C6D','HandleVisibility', 'off')

% SeongL
data = load(file_names{5});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#46FD4B','MarkerSize', 6, 'DisplayName', 'SeongL')
%fitted function
plot(x_points, f(x_points,v_min_old,d_values(5),D_values(5),T_day_values(5),T_month_values(5)), '--', 'LineWidth', 2, 'Color', '#46FD4B','HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')

xlabel('Elapsed Time From Beginning of RT (Month)- $\tau$', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
title('Fit 1','Interpreter','latex')

%saving the plot
saveas(gcf, './results/fit1.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%

% Performs the fit and returns the fitting parameters and the value of the chi-square function
function [param,new_param,chi2_val] = perform_fit(files,N,d,D,T_day,T_month,initial_guess,lower_bound,upper_bound,fitting_function,purpose)
    % Vector with fitting parameters -> v
    % Chi-square function
    chi2 = @(v) residuals(files, N, d, D, T_day, T_month, v, fitting_function,purpose);
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
        %param(1) - K 
        %param(2) - alpha Gy^-1
        %param(3) - alpha/beta Gy
        %param(4) - Td days
        %param(5) - a months^-1
        %param(6) - delta 
end    

% Calculates the residuals of the points of all datafiles
function r = residuals(files, N_list, d_list, D_list, T_day_list, T_month_list, v, f,purpose)
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
            y_fit = f(x(j),v,d,D,T_day,T_month);
            sigma = y(j) .* sqrt(abs((1-y(j)))./N);
            res = (y_fit - y(j)).^2 / sigma.^2;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = s;
end


% Generates a sample for a given datafile (for bootstraping)
function s = sample(data_file)
    x = data_file(:, 1); % x (tau) - elapsed time in months
    y = data_file(:, 2); % y (SR) - survival rate in percentage
    arrayLength = length(x); % filesize
    arraySample = []; % array to store the new sample
    % The length of the sample is equal to the length of the original file
    for a = 1:arrayLength
        b_value = zeros(1,2); % Each value is an array with values x,y
        Index = randi(arrayLength); % Generate a random index within the range of the array
        b_value(1) = x(Index); % x value of the generated point
        b_value(2) = y(Index); % y value of the generated point
        %arraySample=[arraySample,b_value];
        arraySample = vertcat(arraySample, b_value);
    end
    s = arraySample;
end

% Returns the confidence interval of a fitting parameter with replicas 
% obtained from Boostrapping
function ci = ci_boot(param_rep)
    % param_rep -> replicates for the parameter in question
    % Calculating the 95% confidence interval by excluding
    % the most extreme 2.5% of the values in each direction
    ci = prctile(param_rep,[2.5, 97.5]);
end

% Gives the uncertainty lower and upper bounds
function [u_p,u_m] = uncertainties(parameter,ci)
    % parameter -> value of the fitting parameter
    % ci -> confidence interval of that parameter
    u_p = ci(2) - parameter;
    u_m = parameter - ci(1);

end

%%%%%%%%%%%%%%%%%%%%%%%
               


               