function [p,up,goodfit] = fit2(file_names, DataDetails, Bounds)
% function fit2
% HELP: this function returns the results of the second fit - parameters, their uncertainties and plot(s)
%
% INPUT
% * file_names: data files
% * DataDetails: values of the constants presents in the fitting function - N,D,d,T:
%    * N - number of patients
%    * D - prescription dose (Gy)
%    * d - dose per fraction (Gy/fx)
%    * T_day - treatment time (days)
%
% * Bounds: Initial parameter values and bounds of the fitting parameters
%
% OUTPUT
% * p: vector that contains the fitting parameters (K50/K0, alpha, beta, alpha_beta, gamma, Td, sigmak_K0, delta)
% * up: vector that contains the uncertainties of the fitting parameters
% * goodfit: goodness of the fit
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------


% Data from the files:
%x (tau) - elapsed time in months
%y (SR) - survival rate in percentage

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

%v - vector with parameters to find   
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 

% Initial parameter values - defined by the user
% v0 = [2.03, 0.010, 0.000666, 0.00542, 0.65, 0.20];
v0 = cell2mat(Bounds(1,:));

% Define the parameter bounds
% lb = [1.99, 0.009, 0.000647, 0.00495, 0.59, 0.19];
% ub = [2.07, 0.011, 0.000692, 0.00598, 0.71, 0.21];
lb = cell2mat(Bounds(2,:));
ub = cell2mat(Bounds(3,:));

% Define the fitting function
f = @(x,v,d,D,T_day) secondfitting(x,v,d,D,T_day,'fitting');

% Perform the fit 
    % v_min_old: vector with parameters of the fitting function 
    % where we have beta instead of alpha/beta and gamma instead of Td
    % v_min: vector with parameters of the fitting function
    % fval: value of the chi-square function

[v_min_old,v_min,fval] = perform_fit2(file_names,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'fitting',2);

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
        % generating a sample for each file
        data_study=load(file_names{j});
        generated_files{j} = sample(data_study);
    end

    % perform the fit for each replica
        % v_min_boot_old: vector with parameters of the fitting function 
        % where we have beta instead of alpha/beta and gamma instead of Td
        % v_min_boot: parameters of the fitting function for that replica
        % fval_boot: value of the chi-square function

    [v_min_boot_old,v_min_boot,fval_boot] = perform_fit2(generated_files,N_values,d_values,D_values,T_day_values,T_month_values,v0,lb,ub,f,'bootstrapping',2);
   
    fit_replicates = [fit_replicates; v_min_boot_old];
end


% Uncertainties given by the Bootstrapping

u_boot = zeros(n_param); % array to store the uncertainties of the fitting parameters
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
% Results - K50/K0, alpha, beta, alpha_beta, gamma, Td, sigmak/K0, delta

%K50/K0
K50_K0 = v_min(1);
u_K50_K0 = u_boot(1);

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

%sigmak/K0
sigmak_K0 = v_min(5);
u_sigmak_K0 = u_boot(5);

%delta
delta = v_min(6);
u_delta = u_boot(6);

% p: vector that contains the fitting parameters
p = [K50_K0,alpha,beta,alpha_beta,gamma,Td,sigmak_K0,delta];

% up: vector that contains the uncertainties of the fitting parameters
up = [u_K50_K0,u_alpha,u_beta,u_alpha_beta,u_gamma,u_Td,u_sigmak_K0,u_delta];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
labels = cell2mat(DataDetails(:,3));

hold on
x_points = linspace(1, 70, 71);

colors = {'m', 'b', 'k', 'r', 'g', 'c', 'y', '#FF7F50', '#9FE2BF', '#CCCCFF', '#CCD1D1', '#FFF978'};
% studies_names = {'Liang','Dawson','SeongH','SeongM','SeongL'};
markers = {'o','+','*','x','s','d','^','v','>','<','p','h'};

for i = 1:number_studies
    data = load(file_names{i});
    y_plot = [];
    x_plot = [];
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
         'LineWidth',   2, ...
         'Color',       colors{i}, ...
         'Marker',       markers(i), ...
         'MarkerSize',  6, ...
         'DisplayName', string(labels(i,:)))

    errorbar(x,y,errlow,errhigh, ...
             'Color',           colors{i}, ...
             'LineStyle',        'none', ...
             'HandleVisibility', 'off');

    %fitted function   
    for xi = 1:length(x_points)
        sr = secondfitting(x_points(xi),v_min_old,d_values(i),D_values(i),T_day_values(i),'plotting');
        if ~isnan(sr)
            tau = x_points(xi);
            y_plot = [y_plot, sr];
            x_plot = [x_plot, tau];
        end
    end
    plot(x_plot, y_plot, '--', ...
         'LineWidth', 2, ...
         'Color', colors{i}, ...
         'HandleVisibility', 'off')
    hold on;
end

%         %original points
%         colors = {'m', 'b', 'k', 'r', 'g', 'c', 'y', '#FF7F50', '#9FE2BF', '#CCCCFF', '#CCD1D1', '#FFF978'};
%         all_marks = {'o','+','*','x','s','d','^','v','>','<','p','h'};
%         label = cell2mat(DataDetails(i,3));
%         plot(x, y, ...
%             'LineStyle','none', ...
%             'Marker',all_marks{mod(i,12)},...
%             'LineWidth', 2, ...
%             'Color', colors{i}, ...
%             'MarkerSize', 6, ...    
%             'DisplayName', label)
% 
%         %fitted function
%         fit_label = string(strcat('Fit-',label));       
% 
%         for k = 1:length(x_points)
%             sr = fit(x_points(k),v_min,d_values(i),D_values(i),T_day_values(i),'plotting');
%             if ~isnan(sr)
%                 tau = x_points(k);
%                 y_plot = [y_plot, sr];
%                 x_plot = [x_plot, tau];
%            end
%         end
% 
%         plot(x_plot, y_plot, '--', ...
%              'LineWidth', 2, ...
%              'Color', colors{i}, ...
%              'HandleVisibility', 'on',...
%              'DisplayName',fit_label)
% end

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Elapsed Time From Beginning of RT (Month)- $\tau$', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
axis([0 inf 0 100])
title('Fit 2','Interpreter','latex')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
