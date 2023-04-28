clc, clearvars

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL
file_names = {'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
% Data from the files:
%x (tau) - elapsed time in months
%y (SR) - survival rate in percentage
N = [128, 35, 83, 51, 24]; %N - number of patients
d = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day = [28, 42, 37, 37, 37]; %T_day - treatment time in days
T_month = zeros(size(T_day)); %T_month  - treatment time in months
for i = 1:length(T_day)
    tm = T_day(i)/30;
    T_month(i) = tm;
end    
%v - vector with parameters to find   
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

%complete file
complete_x = []
complete_y = []

for i = 1:length(file_names)
   data = load(file_names{i});
   complete_x = [complete_x; data(:,1)];
   complete_y = [complete_y; data(:,2)]; 
end

disp(complete_x);
disp(complete_y);
% Initial parameter values - defined by the user
v0 = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];

% Define the parameter bounds
lb = [0, 0, 0, 0, 1000, 0];
ub = [0.05, 0.05, 0.003, 0.007, 1500, 0.30];

% Define the fitting function
f = @(x,v,d,D,T_day,T_month) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_month)).^v(6)))));

% Define the combined chi-square function
chi2 = @(v)residuals(file_names{1}, N(1), d(1), D(1), T_day(1), T_month(1), v, f);

% Set up the algorithm options
%options = optimoptions('ga', 'PopulationSize', 10, 'MaxGenerations', 1000);
options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);

% Run the algorithm
%v_min = ga(chi2, 6, [], [], [], [], lb, ub, [], options);
[v_min,fval] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% Display the results
disp('Parameters values of that minimize the sum of squares:'); 
disp(['K: ' num2str(v_min(1))]);
disp(['alpha: ' num2str(v_min(2))]);
disp(['beta: ' num2str(v_min(3))]);
disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
disp(['gamma: ' num2str(v_min(4))]);
disp(['Td: ' num2str(log(2) ./ v_min(4))]);
disp(['a: ' num2str(v_min(5))]);
disp(['delta: ' num2str(v_min(6))]);
%PAPER VALUES
%K = (4.2 ± 0.7)*10^(-2) = 0.042 ± 0.007 = [0.035,0.049]
%alpha =  0.037 ± 0.006
%alpha/beta = 14.3 ± 2.0 = [12.3,16.3]
%Td = 114 ± 11 = [103,125]
%a = 1268 ± 184 = [1084,1452]
%delta = 0.16 ± 0.01 = [0.15,0.17]

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
plot(x_points, f(x_points,v_min,d(1),D(1),T_day(1),T_month(1)), '--', 'LineWidth', 2, 'Color', '#FD04FC','HandleVisibility', 'off')

% Dawson
data = load(file_names{2});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 6, 'DisplayName', 'Dawson');
%fitted function
plot(x_points, f(x_points,v_min,d(2),D(2),T_day(2),T_month(2)), '--', 'LineWidth', 2, 'Color', '#0000F7','HandleVisibility', 'off');

% SeongH
data = load(file_names{3});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, '^', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 6, 'DisplayName', 'SeongH')
%fitted function
plot(x_points, f(x_points,v_min,d(3),D(3),T_day(3),T_month(3)), '--', 'LineWidth', 2, 'Color', '#000000','HandleVisibility', 'off')

% SeongM
data = load(file_names{4});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FD6C6D','MarkerSize', 6, 'DisplayName', 'SeongM')
%fitted function
plot(x_points, f(x_points,v_min,d(4),D(4),T_day(4),T_month(4)), '--', 'LineWidth', 2, 'Color', '#FD6C6D','HandleVisibility', 'off')

% SeongL
data = load(file_names{5});
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#46FD4B','MarkerSize', 6, 'DisplayName', 'SeongL')
%fitted function
plot(x_points, f(x_points,v_min,d(5),D(5),T_day(5),T_month(5)), '--', 'LineWidth', 2, 'Color', '#46FD4B','HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 1')

%saving the plot
%saveas(gcf, 'fit1.pdf')

function r = residuals(complete_file, N, d, D, T_day, T_month, v, f)
    s = 0;
    data = load(complete_file);
    x = data(:, 1); %x (tau) - elapsed time in months
    y = data(:, 2); %y (SR) - survival rate in percentage
    for i = 1:length(x)
        y_fit = f(x(i),v,d,D,T_day,T_month);
        sigma = y(i) .* sqrt(abs((1-y(i)))./N);
        res = (y_fit - y(i)).^2 / sigma.^2;
        s = res + s;
    end
    r = s;
end