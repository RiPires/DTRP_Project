clc, clearvars %clear

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
%Error Bars of the files points
error_bars_top = {'datafiles/error bars/errorsbars_top_Liang.csv',...
    'datafiles/error bars/errorsbars_top_Dawson.csv',...
    'datafiles/error bars/errorsbars_top_SeongH.csv',...
    'datafiles/error bars/errorsbars_top_SeongM.csv',...
    'datafiles/error bars/errorsbars_top_SeongL.csv'};
error_bars_bot = {'datafiles/error bars/errorsbars_bot_Liang.csv',...
    'datafiles/error bars/errorsbars_bot_Dawson.csv',...
    'datafiles/error bars/errorsbars_bot_SeongH.csv',...
    'datafiles/error bars/errorsbars_bot_SeongM.csv',...
    'datafiles/error bars/errorsbars_bot_SeongL.csv'};
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
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 

% Initial parameter values - defined by the user
v0 = [2.03, 0.010, 0.000666, 0.00542, 0.65, 0.20];

% Define the parameter bounds
lb = [1.99, 0.009, 0.000647, 0.00495, 0.59, 0.19];
ub = [2.07, 0.011, 0.000692, 0.00598, 0.71, 0.21];

% Fitting function
f = @(x,v,d,D,T_day) fitting(x,v,d,D,T_day,'fitting');

% Perform the fit 
    % v_min_old: vector with parameters of the fitting function 
    % where we have beta instead of alpha/beta and gamma instead of Td
    % v_min: vector with parameters of the fitting function
    % fval: value of the chi-square function

[v_min_old,v_min,fval] = perform_fit(file_names,N_values,d_values,D_values,T_day_values,v0,lb,ub,f,'fitting');


% Root-mean-square deviation function
% rmsd = rmsd_residuals(file_names, N_values, d_values, D_values, T_day_values, v_min, f);
% Goodness of the fit
% dof = no of degrees of freedom = 
% = no. of clinically observed survival data points- no. of free parameters in the fitting function
dof = n_points-n_param;
goodfit = fval/dof;

% CIs (confidence intervals) calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstraping 

fit_replicates = []; % array to store the replicas of the fitting parameters
n = 1000; % number of replicates -> we will get 1000 new values for the fitting parameters

% comment later 
%%%%%%%%%%%%%%%%%%%%%%
histogram_study1 = [];
histogram_study2 = [];
histogram_study3 = [];
histogram_study4 = [];
histogram_study5 = [];
histograms = {histogram_study1,histogram_study2,histogram_study3,...
     histogram_study4,histogram_study5};
%%%%%%%%%%%%%%%%%%%%%%

for i = 1:n 
    % cell array to store the samples for each replicate
    generated_files = cell(1, number_studies);
    for j = 1:number_studies
        % generating a sample for each file
        data_study=load(file_names{j});
        generated_files{j} = sample(data_study);
        histograms{j} = vertcat(histograms{j},sample(data_study));
    end

    % perform the fit for each replica
        % v_min_boot_old: vector with parameters of the fitting function 
        % where we have beta instead of alpha/beta and gamma instead of Td
        % v_min_boot: parameters of the fitting function for that replica
        % fval_boot: value of the chi-square function

    [v_min_boot_old,v_min_boot,fval_boot] = perform_fit(generated_files,N_values,d_values,D_values,T_day_values,v0,lb,ub,f,'bootstrapping');
   
    fit_replicates = [fit_replicates; v_min_boot_old];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotting the histogram for each file/study
% comment later
figure;
title('Histogram of Bootstrapped Replicas');
for ns = 1:number_studies % for each study
    points = load(file_names{ns}); % open the file
    count_points = [];
    for p = 1:size(points,1) % for each point in the file
        c = sum(histograms{ns}(:,1) == points(p));
        % c = number of counts
        count_points = horzcat(count_points,c);
    end
    
    subplot(2,3,ns); % subplot for each file
    % create histogram with counts
    % Create histogram with counts
    bin_edges = 1:numel(count_points); % Bin edges based on the number of counts
    bar(bin_edges, count_points);

    xlabel(['Study ' num2str(ns)]);
    ylabel('Frequency');
end
  
% saving the plot
saveas(gcf, './results/histograms_boot2.pdf')
% clear the figure
clf;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Uncertainties given by the Bootstrapping

% u_boot_plus = zeros(n_param); % array to store the upper uncertainty of the fitting parameters
% u_boot_minus = zeros(n_param); % array to store the lower uncertainty of the fitting parameters

u_boot = zeros(n_param); % array to store the uncertainties of the fitting parameters
CI_u = zeros(n_param); % array to store the upper value of the confidence intervals of the fitting parameters
CI_l = zeros(n_param); % array to store the lower value of the confidence intervals of the fitting parameters

% for i = 1:n_param
%     CI = ci_boot(fit_replicates(:,i)); % confidence interval
%     CI_u(i) = CI(2);
%     CI_l(i) = CI(1);
%     [u_plus,u_minus] = uncertainties(v_min(i),CI);
%     u_boot_plus(i) = u_plus;
%     u_boot_minus(i) = u_minus;
% end

% calculating the uncertainties of the parameters
for i = 1:n_param
    u_boot(i) = std(fit_replicates(:,i));
end

% calculating the uncertainty of Td (index 4)
% Td = ln2/gamma
% gamma = v_min_old(4)
% uncertainty(gamma) = u_boot(4)
u_Td = uncertainty_quocient(log(2),v_min_old(4),0,u_boot(4));
% update the value of u_boot
u_boot(4) = u_Td;

% calculating the uncertainty of alpha/beta (index 3)
% alpha/beta
% alpha = v_min_old(2)
% beta = v_min_old(3)
% uncertainty(alpha) = u_boot(2)
% uncertainty(beta) = u_boot(3)
u_beta = uncertainty_quocient(v_min_old(2),v_min_old(3),u_boot(2),u_boot(3));
% update the value of u_boot
u_boot(3) = u_beta;

% calculating the confidence intervals (CI) of the parameters
for np = 1:n_param
    CI_l(np) = v_min(np) - u_boot(np);
    CI_u(np) = v_min(np) + u_boot(np);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save the results in a file
parameters_names = {'K50/K0','alpha','alpha/beta','Td','sigmak/K0','delta'};

myfile = fopen('./results/fit2.txt', 'w');  

fprintf(myfile, 'Goodness of the fit: %f\n', goodfit);
fprintf(myfile, '\n');
fprintf(myfile, 'Uncertainties given by the Bootstrapping Method:\n');
fprintf(myfile, 'Parameters values that minimize the sum of squares: value [- uncertainty + uncertainty]:\n');
fprintf(myfile, '-----------------\n');
formatSpec = '%s: %.6f [-%.6f + %.6f]\n CI: [%.6f,%.6f]\n';
for i = 1:length(parameters_names)
    fprintf(myfile, formatSpec, parameters_names{i}, v_min(i), u_boot(i),u_boot(i), CI_l(i),CI_u(i));
end

% Close the file
fclose(myfile);


% Plotting
colors = {'#FD04FC','#0000F7','#000000','#FD6C6D','#46FD4B'};
studies_names = {'Liang','Dawson','SeongH','SeongM','SeongL'};
markers = {'v','o','^','s','o'};

hold on
x_points = linspace(1, 70, 71);

for i = 1:number_studies
    data = load(file_names{i});
    errhigh = load(error_bars_top{i});
    errlow = load(error_bars_bot{i});
    y_plot = [];
    x_plot = [];
    x = data(:,1);
    y = data(:,2);
    %original points
    plot(x, y, markers{i}, 'LineWidth', 2, 'Color', colors{i},'MarkerSize', 6, 'DisplayName', studies_names{i})
    errorbar(x,y,errlow,errhigh,'Color',colors{i},'LineStyle','none','HandleVisibility', 'off');
    %fitted function   
    for xi = 1:length(x_points)
        sr = fitting(x_points(xi),v_min_old,d_values(i),D_values(i),T_day_values(i),'plotting');
        if ~isnan(sr)
            tau = x_points(xi);
            y_plot = [y_plot, sr];
            x_plot = [x_plot, tau];
        end
    end
    plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', colors{i},'HandleVisibility', 'off')
    hold on;
end


%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')

xlabel('Elapsed Time From Beginning of RT (Month)- $\tau$', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
title('Fit 2','Interpreter','latex')

%saving the plot
saveas(gcf, './results/fit2.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%

% Performs the fit and returns the fitting parameters and the value of the chi-square function
function [param,new_param,chi2_val] = perform_fit(files,N,d,D,T_day,initial_guess,lower_bound,upper_bound,fitting_function,purpose)
    % Vector with fitting parameters -> v
    % Chi-square function
    chi2 = @(v) chi2_residuals(files, N, d, D, T_day, v, fitting_function,purpose);
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


function result = fitting(tau,v,d,D,T_day,purpose)
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
        

% Calculates the residuals of the points of all datafiles
% to obtain the Chi-square function
function r = chi2_residuals(files, N_list, d_list, D_list, T_day_list, v, f,purpose)
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
        sf = 0; %sum for the points of a specific file

        for j = 1:length(x)
            y_fit = f(x(j),v,d,D,T_day);
            sigma = y(j) .* sqrt(abs((1-y(j)))./N);
            res = (y_fit - y(j)).^2 / sigma.^2;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = s;
end

% Calculates the residuals of the points of all datafiles
% to obtain the Root-mean-square deviation function
function r = rmsd_residuals(files, N_list, d_list, D_list, T_day_list, v, f)
    s = 0; %sum for all the points of all the files
    for i = 1:length(files)
        data = load(files{i});
        x = data(:, 1); %x (tau) - elapsed time in months
        y = data(:, 2); %y (SR) - survival rate in percentage
        N = N_list(i);
        d = d_list(i);
        D = D_list(i);
        T_day = T_day_list(i);
        sf = 0; %sum for the points of a specific file

        for j = 1:length(x)
            y_fit = f(x(j),v,d,D,T_day);
            res = (y_fit - y(j)).^2 / N;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = sqrt(s);
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

% Returns the uncertainty of a quocient of two parameters a, and b
% with uncertainties un_a, and un_b, respectively
function uq = uncertainty_quocient(a,b,un_a,un_b)
    uq = sqrt( (1/b^2)*(un_a)^2 + ((-a/b^2)^2)*((un_b)^2) );
end

% Returns the confidence interval of a fitting parameter with replicas 
% obtained from Bootstrapping
% function ci = ci_boot(param_rep)
    % param_rep -> replicates for the parameter in question
    % Calculating the 95% confidence interval by excluding
    % the most extreme 2.5% of the values in each direction
    % ci = prctile(param_rep,[2.5, 97.5]);
% end

% Gives the uncertainty lower and upper bounds
% function [u_p,u_m] = uncertainties(parameter,ci)
    % parameter -> value of the fitting parameter
    % ci -> confidence interval of that parameter
    % u_p = ci(2) - parameter;
    % u_m = parameter - ci(1);

% end

%%%%%%%%%%%%%%%%%%%%%%%
               





