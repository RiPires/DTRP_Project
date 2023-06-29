function [K, alpha, beta, gamma, a, Td, delta] = fit1(file_names, DataDetails, Bounds)

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


%v - vector with parameters to find   
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

% Initial parameter values - defined by the user
%v0 = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];
v0 = cell2mat(Bounds(1,:));

% Define the parameter bounds
%lb = [0, 0, 0, 0, 1000, 0];
%ub = [0.05, 0.05, 0.003, 0.007, 1500, 0.30];
lb = cell2mat(Bounds(2,:));
ub = cell2mat(Bounds(3,:));

% Define the fitting function
f = @(x,v,d,D,T_day,T_month) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_month)).^v(6)))));

% Chi-square function
chi2 = @(v) residuals(file_names, N_values, d_values, D_values, T_day_values, T_month_values, v, f);

% Set up the algorithm options
%options = optimoptions('ga', 'PopulationSize', 10, 'MaxGenerations', 1000);
options = optimoptions('fmincon', ...
                       'MaxIterations',1000, ...
                       'TolFun',1e-9,'TolX',1e-9);

% Run the algorithm
%v_min = ga(chi2, 6, [], [], [], [], lb, ub, [], options);
[v_min,~,~,~,~,~,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% Uncertainties
cm = inv(hessian); %cm -> covariance matrix
un = zeros(size(v_min)); %un -> vector with uncertainties
d_cm = diag(cm); %d_cm -> diagonal of the covariance matrix
for i = 1:length(un)
    un(i) = sqrt(d_cm(i));
end

% Display the results
disp('Parameters values of that minimize the sum of squares (value ± std):'); 

K = num2str(v_min(1));
alpha = num2str(v_min(2));
beta = num2str(v_min(3));
gamma = num2str(v_min(4));
a = num2str(v_min(5));
Td = num2str(log(2) ./ v_min(4));
delta = num2str(v_min(6));
disp(['K: ', K, ' ± ', num2str(un(1))]);
disp(['alpha: ', alpha, ' ± ', num2str(un(2))]);
disp(['beta: ', beta, ' ± ', num2str(un(3))]);
disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
disp(['gamma: ', gamma, ' ± ', num2str(un(4))]);
disp(['Td: ' Td]);
disp(['a: ', a, ' ± ', num2str(un(5))]);    
disp(['delta: ', delta, ' ± ', num2str(un(6))]);



% Plotting
hold on
x_points = linspace(0, 70, 71);
disp(numel(file_names))
for i = 1:numel(file_names)
        data = load(file_names{i});
        x = data(:, 1);
        y = data(:, 2);

        %original points
        colors = {'m', 'b', 'k', 'r', 'g', 'c', 'y', '#FF7F50', '#9FE2BF', '#CCCCFF', '#CCD1D1', '#FFF978'};
        all_marks = {'o','+','*','x','s','d','^','v','>','<','p','h'};

        label = cell2mat(DataDetails(i,3));
        plot(x, y, ...
            'LineStyle','none', ...
            'Marker',all_marks{mod(i,12)},...
            'LineWidth', 2, ...
            'Color', colors{i}, ...
            'MarkerSize', 6, ...    
            'DisplayName', label)
        
        fit_label = string(strcat('Fit-',label));

        %fitted function
        plot(x_points, f(x_points,v_min,d_values(i),D_values(i),T_day_values(i),T_month_values(i)), ...
            '--', ...
            'LineWidth', 2, ...
            'Color', colors{i}, ...
            'DisplayName', fit_label,...
            'HandleVisibility', 'on')
 end

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Time (months)')
ylabel('SR (%)')
axis([0 inf 0 100])
title('Fit 1')

%saving the plot
%saveas(gcf, 'fit1.pdf')



end %main