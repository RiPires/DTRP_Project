function [p,up,goodfit] = fit1(file_names, DataDetails, Bounds) 
% function fit1
% HELP: this function returns the results of the first fit - parameters, their uncertainties and plot(s)
%
% INPUT
% * file_names: names of the study(ies) of the data file(s)
% * DataDetails: values of the constants presents in the fitting function - N,D,d,T:
%    * N - number of patients
%    * D - prescription dose (Gy)
%    * d - dose per fraction (Gy/fx)
%    * T_day - treatment time (days)
%
% * Bounds: Initial parameter values and bounds of the fitting parameters
%
% OUTPUT
% * p: vector that contains the fitting parameters (K, alpha, beta, alpha_beta, gamma, Td, a, delta)
% * up: vector that contains the uncertainties of the fitting parameters
% * goodfit: goodness of the fit
%
%


% Data from the files:
% x (tau) - elapsed time in months
% y (SR) - survival rate in percentage


N_values = cell2mat(DataDetails(:,4));      % N - number of patients
D_values = cell2mat(DataDetails(:,5));      % D - prescription dose Gy
d_values = cell2mat(DataDetails(:,6));      % d - dose per fraction Gy/fx
T_day_values = cell2mat(DataDetails(:,7));  % T_day - treatment time in days


T_month_values = zeros(size(T_day_values)); %T_month  - treatment time in months
for i = 1:length(T_day_values)
    tm = T_day_values(i)/30;
    T_month_values(i) = tm;
end

number_studies = numel(file_names);
n_param = 6; %n_param - number of fitting parameters

n_points = 0; %n_points - number of points from all the files
for i = 1:length(file_names)
    file = load(file_names{i});
    s = size(file);
    n_points = n_points + s(1);
end

% v - vector with parameters to find   
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

% Initial parameter values - defined by the user
% v0 = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];
v0 = cell2mat(Bounds(1,:));

% Define the parameter bounds
% lb = [0, 0, 0, 0, 1000, 0];
% ub = [0.05, 0.05, 0.003, 0.007, 1500, 0.30];
lb = cell2mat(Bounds(2,:));
ub = cell2mat(Bounds(3,:));

% Define the fitting function
f = @(x,v,d,D,T_day,T_month) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_month)).^v(6)))));

% Perform the fit 
    % v_min_old: vector with parameters of the fitting function 
    % where we have beta instead of alpha/beta and gamma instead of Td
    % v_min: vector with parameters of the fitting function
    % fval: value of the chi-square 

[v_min_old,v_min,fval] = perform_fit1(file_names,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'fitting',1);

%v_min - vector with found parameters 
    %v_min(1) - K 
    %v_min(2) - alpha Gy^-1
    %v_min(3) - alpha/beta Gy
    %v_min(4) - Td days
    %v_min(5) - a months^-1
    %v_min(6) - delta 


% Goodness of the fit
% dof = no of degrees of freedom = 
% = no. of clinically observed survival data points- no. of free parameters in the fitting function
dof = n_points-n_param;
% goodfit = rmsd/dof;
goodfit = fval/dof; 

% CIs (confidence intervals) calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstraping 

fit_replicates = []; % array to store the replicas of the fitting parameters
n = 10; % number of replicates -> we will get 1000 new values for the fitting parameters

for i = 1:n 
    % cell array to store the samples for each replicate
    generated_files = cell(1, number_studies);
    for j = 1:number_studies
        % generating a sample for each file/study
        data_study=load(file_names{j});
        generated_files{j} = sample(data_study);
    end

    % perform the fit for each replica
        % v_min_boot_old: vector with parameters of the fitting function 
        % where we have beta instead of alpha/beta and gamma instead of Td
        % v_min_boot: parameters of the fitting function for that replica
        % fval_boot: value of the chi-square function

    [v_min_boot_old,v_min_boot,fval_boot] = perform_fit1(generated_files,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'bootstrapping',1);

    fit_replicates = [fit_replicates; v_min_boot_old];
    
end


% Uncertainties given by the Bootstrapping

u_boot = zeros(n_param); % array to store the uncertainties of the fitting parameters.                           
CI_u = zeros(n_param); % array to store the upper value of the confidence intervals of the fitting parameters
CI_l = zeros(n_param); % array to store the lower value of the confidence intervals of the fitting parameters


% calculating the uncertainties of the parameters
for i = 1:n_param
    u_boot(i) = std(fit_replicates(:,i));
end

% calculating the uncertainty of Td
% Td = ln2/gamma
% gamma = v_min_old(4)
% uncertainty(gamma) = u_boot(4)
u_Td = uncertainty_quocient(log(2),v_min_old(4),0,u_boot(4));

% calculating the uncertainty of alpha/beta
% alpha/beta
% alpha = v_min_old(2)
% beta = v_min_old(3)
% uncertainty(alpha) = u_boot(2)
% uncertainty(beta) = u_boot(3)
u_alpha_beta = uncertainty_quocient(v_min_old(2),v_min_old(3),u_boot(2),u_boot(3));

% calculating the confidence intervals (CI) of the parameters
for np = 1:n_param
    CI_l(np) = v_min(np) - u_boot(np);
    CI_u(np) = v_min(np) + u_boot(np);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results - K, alpha, beta, alpha_beta, gamma, Td, a, delta

%K
K = v_min(1);
u_K = u_boot(1);

%alpha
alpha = v_min(2);
u_alpha = u_boot(2);

%beta
beta = v_min_old(3);
u_beta = u_boot(3);

%alpha/beta
alpha_beta = v_min(3);

%gamma
gamma = v_min_old(4);
u_gamma = u_boot(4);

%Td
Td = v_min(4);

%a
a = v_min(5);
u_a = u_boot(5);

%delta
delta = v_min(6);
u_delta = u_boot(6);

% p: vector that contains the fitting parameters
p = [K,alpha,beta,alpha_beta,gamma,Td,a,delta];

% up: vector that contains the uncertainties of the fitting parameters
up = [u_K,u_alpha,u_beta,u_alpha_beta,u_gamma,u_Td,u_a,u_delta];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
% disp(DataDetails(:,3));
labels = cell2mat(DataDetails(:,3));
% disp(labels);

hold on
x_points = linspace(0, 70, 71);

colors = {'m', 'b', 'k', 'r', 'g', 'c', 'y', '#FF7F50', '#9FE2BF', '#CCCCFF', '#CCD1D1', '#FFF978'};
% studies_names = {'Liang','Dawson','SeongH','SeongM','SeongL'};
markers = {'o','+','*','x','s','d','^','v','>','<','p','h'};

for i = 1:number_studies
    data = load(file_names{i});
    x = data(:,1);
    y = data(:,2);

    if numel(data(1,:))==2
        errhigh = zeros(numel(x),1);
        errlow = zeros(numel(x),1);
    elseif numel(data(1,:))==4
        errhigh = data(:,3);
        errlow = data(:,4);
    end
    %original points
    plot(x, y, markers{i}, ...
         'LineWidth', 2, ...
         'Color', colors{i}, ...
         'MarkerSize', 6, ...
         'DisplayName', string(labels(i,:)))
    errorbar(x,y,errlow,errhigh,'Color',colors{i},'LineStyle','none','HandleVisibility', 'off');
    %fitted function   
    plot(x_points, f(x_points,v_min_old,d_values(i),D_values(i),T_day_values(i),T_month_values(i)), '--', 'LineWidth', 2, 'Color', colors{i},'HandleVisibility', 'off')
end

% disp(numel(file_names))
% for i = 1:numel(file_names)
%         data = load(file_names{i});
%         x = data(:, 1);
%         y = data(:, 2);
% 
%         %original points
%         colors = {'m', 'b', 'k', 'r', 'g', 'c', 'y', '#FF7F50', '#9FE2BF', '#CCCCFF', '#CCD1D1', '#FFF978'};
%         all_marks = {'o','+','*','x','s','d','^','v','>','<','p','h'};
% 
%         label = cell2mat(DataDetails(i,3));
%         plot(x, y, ...
%             'LineStyle','none', ...
%             'Marker',all_marks{mod(i,12)},...
%             'LineWidth', 2, ...
%             'Color', colors{i}, ...
%             'MarkerSize', 6, ...    
%             'DisplayName', label)
% 
%         fit_label = string(strcat('Fit-',label));
% 
%         %fitted function
%         plot(x_points, f(x_points,v_min,d_values(i),D_values(i),T_day_values(i),T_month_values(i)), ...
%             '--', ...
%             'LineWidth', 2, ...
%             'Color', colors{i}, ...
%             'DisplayName', fit_label,...
%             'HandleVisibility', 'on')
%  end


%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Elapsed Time From Beginning of RT (Month)- $\tau$', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
axis([0 inf 0 100])
title('Fit 1','Interpreter','latex')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
                              