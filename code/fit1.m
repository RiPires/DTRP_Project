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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%points from all the files%%%
%xx = []; 
%yy = []; 
%for i = 1:length(file_names)
%    data = load(file_names{i});
%    xx = [xx; data(:,1)];
%    yy = [yy; data(:,2)];
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Chi-square function
chi2 = @(v) residuals(file_names, N_values, d_values, D_values, T_day_values, T_month_values, v, f);

% Set up the algorithm options
%options = optimoptions('ga', 'PopulationSize', 10, 'MaxGenerations', 1000);
options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);

% Run the algorithm
%v_min = ga(chi2, 6, [], [], [], [], lb, ub, [], options);
[v_min,fval,exitflag,output,lambda,grad,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% CIs (confidence intervals) calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bootstraping 
n = 1000; % number of samples

% The function bootstrap generates n new arrays with data for each study
% Each array is a replica

for i = 1:number_files
    array_name = sprintf('array_%d', i);
    eval([array_name, ' = [];']); % Create empty array for a file
end

disp(array_1); % Display array_1

% bootstrap(file_name, n)

% Generating n vectors v with the fitting parameters by doing
% n minimizations, one for each replica

v_min_boot = []; 
% list of vectors with the parameters of the fittings
% performed on the bootstraping data

% Run the bootstrap function
boo = bootstrap(file_names, n);

for i = 1:n
    % Data for each replica
    data = cell(1, number_studies);
    for j = 1:number_studies
        data{j} = boo{j}{i};
    end
    % Chi-square function
    chi2_boo = @(v) boo_residuals(data, number_studies, N_values, d_values, D_values, T_day_values, T_month_values, v, f);
    v_min_boot = [v_min_boot; fmincon(chi2_boo, v0, [], [], [], [], lb, ub, [], options)];

    % Open a file for writing
    file = fopen('param_vec.txt', 'w');
    % Print the vector elements to the file
    fprintf(file, '%d\n', v_min_boot);
    % Close the file
    fclose(file);

end

v_boot_1 = v_min_boot(:,1); % K
v_boot_2 = v_min_boot(:,2); % alpha
v_boot_3 = v_min_boot(:,3); % beta
v_boot_4 = v_min_boot(:,4); % gamma
v_boot_5 = v_min_boot(:,5); % a
v_boot_6 = v_min_boot(:,6); % delta

% Calculating the 95% confidence interval by excluding
% the most extreme 2.5% of the values in each direction
conf_interval_1 = prctile(v_boot_1, [2.5, 97.5]);
conf_interval_2 = prctile(v_boot_2, [2.5, 97.5]);
conf_interval_3 = prctile(v_boot_3, [2.5, 97.5]);
conf_interval_4 = prctile(v_boot_4, [2.5, 97.5]);
conf_interval_5 = prctile(v_boot_5, [2.5, 97.5]);
conf_interval_6 = prctile(v_boot_6, [2.5, 97.5]);


% Uncertainties
% K
u_1_plus = conf_interval_1(2) - v_min(1);
u_1_minus = v_min(1) - conf_interval_1(1);
% alpha
u_2_plus = conf_interval_2(2) - v_min(2);
u_2_minus = v_min(2) - conf_interval_2(1);
% beta
u_3_plus = conf_interval_3(2) - v_min(3);
u_3_minus = v_min(3) - conf_interval_3(1);
% gamma
u_4_plus = conf_interval_4(2) - v_min(4);
u_4_minus = v_min(4) - conf_interval_4(1);
% a
u_5_plus = conf_interval_5(2) - v_min(5);
u_5_minus = v_min(5) - conf_interval_5(1);
% delta
u_6_plus = conf_interval_6(2) - v_min(6);
u_6_minus = v_min(6) - conf_interval_6(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Profile-Likelihood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bundle of Curves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 

% Display the results
disp('Parameters values of that minimize the sum of squares: value (- uncertainty + uncertainty):'); 
disp(['K: ', num2str(v_min(1)), ' (- ', num2str(u_1_minus),'+',num2str(u_1_plus),')']);
disp(['alpha: ', num2str(v_min(2)), ' (- ', num2str(u_2_minus),'+',num2str(u_2_plus),')']);
disp(['beta: ', num2str(v_min(3)), ' (- ', num2str(u_3_minus),'+',num2str(u_3_plus),')']);
disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
disp(['gamma: ', num2str(v_min(4)), ' (- ', num2str(u_4_minus),'+',num2str(u_4_plus),')']);
disp(['a: ', num2str(v_min(5)), ' (- ', num2str(u_5_minus),'+',num2str(u_5_plus),')']);
disp(['Td: ' num2str(log(2) ./ v_min(4))]);
disp(['delta: ', num2str(v_min(6)), ' (- ', num2str(u_6_minus),'+',num2str(u_6_plus),')']);

disp('Confidence Intervals:')
disp(['K: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);
disp(['alpha: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);
disp(['beta: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);
disp(['alpha/beta: ' ]);
disp(['gamma: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);
disp(['a: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);
disp(['Td: ' ]);
disp(['delta: [', num2str(conf_interval_1(2)), ', ', num2str(conf_interval_1(1)),']']);

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
plot(x_points, f(x_points,v_min,d_values(1),D_values(1),T_day_values(1),T_month_values(1)), '--', 'LineWidth', 2, 'Color', '#FD04FC','HandleVisibility', 'off')

% Dawson
data = load(file_names{2});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 6, 'DisplayName', 'Dawson');
%fitted function
plot(x_points, f(x_points,v_min,d_values(2),D_values(2),T_day_values(2),T_month_values(2)), '--', 'LineWidth', 2, 'Color', '#0000F7','HandleVisibility', 'off');

% SeongH
data = load(file_names{3});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, '^', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 6, 'DisplayName', 'SeongH')
%fitted function
plot(x_points, f(x_points,v_min,d_values(3),D_values(3),T_day_values(3),T_month_values(3)), '--', 'LineWidth', 2, 'Color', '#000000','HandleVisibility', 'off')

% SeongM
data = load(file_names{4});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FD6C6D','MarkerSize', 6, 'DisplayName', 'SeongM')
%fitted function
plot(x_points, f(x_points,v_min,d_values(4),D_values(4),T_day_values(4),T_month_values(4)), '--', 'LineWidth', 2, 'Color', '#FD6C6D','HandleVisibility', 'off')

% SeongL
data = load(file_names{5});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#46FD4B','MarkerSize', 6, 'DisplayName', 'SeongL')
%fitted function
plot(x_points, f(x_points,v_min,d_values(5),D_values(5),T_day_values(5),T_month_values(5)), '--', 'LineWidth', 2, 'Color', '#46FD4B','HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 1')

%saving the plot
%saveas(gcf, 'fit1.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%

function r = residuals(files, N_list, d_list, D_list, T_day_list, T_month_list, v, f)
    s = 0; %sum for all the points of all the files
    for i = 1:length(files)
        data = load(files{i});
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

%%%%%%%%%%%%%%%%%%%%%%%
% Bootstraping 
% This function generates n replicas for the selected file
function b_replicas = bootstrap(list_files, file_number, n)
    b_replicas = []; % array to store the file replicas
    % Values of the selected study
    data = load(list_files{file_number});
    x = data(:, 1); % x (tau) - elapsed time in months
    y = data(:, 2); % y (SR) - survival rate in percentage
    arrayLength = length(x); % Get the length of the array (=filesize)

    for i = 1:n % Creating bootstrap for each of the n replicas
        replica = []; % array to store the new samples
        % The number of samples is equal to the original file size
        for j = 1:arrayLength % Creating one sample at time
            b_sample = zeros(1,2); % Each sample is an array with values x,y
            % Create a bootstrap sample by selecting a random value of x
            Index = randi(arrayLength); % Generate a random index within the range of the array
            b_sample(1) = x(Index); % x value of the sample
            b_sample(2) = y(Index); % y value of the sample
            replica = vertcat(replica, b_sample);
        end
       
    end
end
   
        



%This function calculates the residuals for the generated data
    function br = boo_residuals(data_boo,number_files, N_list, d_list, D_list, T_day_list, T_month_list, v, f)
    s = 0; %sum for all the points of all the files
    for i = 1:number_files
        data = data_boo{i};
        x = data(:, 1); %x (tau) - elapsed time in months
        x = cell2mat(x);
        y = data(:, 2); %y (SR) - survival rate in percentage
        y = cell2mat(y);
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
    br = s;
end
%%%%%%%%%%%%%%%%%%%%%%%
               