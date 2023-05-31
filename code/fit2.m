clc, clearvars %clear

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
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


% Chi-square function
chi2 = @(v) residuals(file_names, N_values, d_values, D_values, T_day_values, v, f);


%fmincon
% Set up the algorithm options
options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);
% Run the algorithm
[v_min,fval,exitflag,output,lambda,grad,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% Display the results
% real results
% K50/K0 = 2.03±0.04
% alpha = 0.010±0.001
% alpha/beta = 15.0±2.0
% sigmak/K0 = 0.65±0.06
% Td = 128±12
% delta = 0.20±0.01

disp('Parameters values of that minimize the sum of squares (value):'); 
disp(['K50/K0: ', num2str(v_min(1))]);
disp(['alpha: ', num2str(v_min(2))]);
disp(['beta: ', num2str(v_min(3))]);
disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
disp(['gamma: ', num2str(v_min(4))]);
disp(['sigmak/K0: ', num2str(v_min(5))]);
disp(['Td: ' num2str(log(2) ./ v_min(4))]);
disp(['delta: ', num2str(v_min(6))]);
% disp('Parameters values of that minimize the sum of squares (value ± std):'); 
% disp(['K50/K0: ', num2str(v_min(1)), ' ± ', num2str(un(1))]);
% disp(['alpha: ', num2str(v_min(2)), ' ± ', num2str(un(2))]);
% disp(['beta: ', num2str(v_min(3)), ' ± ', num2str(un(3))]);
% disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
% disp(['gamma: ', num2str(v_min(4)), ' ± ', num2str(un(4))]);
% disp(['sigmak/K0: ', num2str(v_min(5)), ' ± ', num2str(un(5))]);
% disp(['Td: ' num2str(log(2) ./ v_min(4))]);
% disp(['delta: ', num2str(v_min(6)), ' ± ', num2str(un(6))]);

% Plotting
hold on
x_points = linspace(1, 70, 71);

v_min = [2.04, 0.01, 0.00067, 0.0054, 0.65, 0.20];

% Liang
data = load(file_names{1});

y_plot = [];
x_plot = [];
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 6, 'DisplayName', 'Liang')
%fitted function  
for i = 1:length(x_points)
    sr = fitting(x_points(i),v_min,d_values(1),D_values(1),T_day_values(1),'plotting');
    if ~isnan(sr)
        tau = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, tau];
   end
end

plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FD04FC','HandleVisibility', 'off')
hold on;


% Dawson
data = load(file_names{2});

y_plot = [];
x_plot = [];
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 6, 'DisplayName', 'Dawson');
%fitted function  
for i = 1:length(x_points)
    sr = fitting(x_points(i),v_min,d_values(2),D_values(2),T_day_values(2),'plotting');
    if ~isnan(sr)
        tau = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, tau];
   end
end

plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#0000F7','HandleVisibility', 'off');
hold on;

 
% SeongH
data = load(file_names{3});

y_plot = [];
x_plot = [];
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, '^', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 6, 'DisplayName', 'SeongH');
%fitted function  
for i = 1:length(x_points)
    sr = fitting(x_points(i),v_min,d_values(3),D_values(3),T_day_values(3),'plotting');
    if ~isnan(sr)
        tau = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, tau];
   end
end

plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#000000','HandleVisibility', 'off');
hold on;

% SeongM
data = load(file_names{4});

y_plot = [];
x_plot = [];
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FD6C6D','MarkerSize', 6, 'DisplayName', 'SeongM');
%fitted function  
for i = 1:length(x_points)
    sr = fitting(x_points(i),v_min,d_values(4),D_values(4),T_day_values(4),'plotting');
    if ~isnan(sr)
        tau = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, tau];
   end
end

plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FD6C6D','HandleVisibility', 'off');
hold on;

% SeongL
data = load(file_names{5});

y_plot = [];
x_plot = [];
x = data(:, 1);
y = data(:, 2);
%original points
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#46FD4B','MarkerSize', 6, 'DisplayName', 'SeongL');
%fitted function  
for i = 1:length(x_points)
    sr = fitting(x_points(i),v_min,d_values(5),D_values(5),T_day_values(5),'plotting');
    if ~isnan(sr)
        tau = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, tau];
   end
end

plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#46FD4B','HandleVisibility', 'off');
hold on;

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 2')

%saving the plot
%saveas(gcf, 'fit2.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%

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
        

function r = residuals(files, N_list, d_list, D_list, T_day_list, v, f)
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
            sigma = y(j) .* sqrt(abs((1-y(j)))./N);
            res = (y_fit - y(j)).^2 / sigma.^2;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = s;
end


