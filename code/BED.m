clc, clearvars %clear

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
% Data from the files:
%y (SR) - survival rate in percentage
%tau - elapsed time in months
%%%points from all the files%%%
tau_list = []; 
y_list = []; 
for i = 1:length(file_names)
    data = load(file_names{i});
    tau_list = [tau_list; data(:,1)];
    y_list = [y_list; data(:,2)];
end

N_values = [128, 35, 83, 51, 24]; %N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]; %T_day - treatment time in days
T_day_mean = mean(T_day_values); %CONFIRM THIS!%
T_month_values = zeros(size(T_day_values)); %T_month  - treatment time in months
for i = 1:length(T_day_values)
    tm = T_day_values(i)/30;
    T_month_values(i) = tm;
end  

v = [2.03, 0.010, 15.0, 0.0054, 0.65, 0.20];
%v - vector with parameters obtained from fit2   
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - alpha/beta Gy
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 

%x (BED) - Biologically effective dose (Gy)
x_values = zeros(size(N_values));
for i = 1:length(x_values)
    bed = (1+(d_values(i)/v(3)))*D_values(i) - (v(4)*T_day_values(i))/v(2);
    x_values(i) = bed;
end  

disp('BED values:'); 
disp(['Liang: ', num2str(x_values(1))]);
disp(['Dawson: ', num2str(x_values(2))]);
disp(['SeongH: ', num2str(x_values(3))]);
disp(['SeongM: ', num2str(x_values(4))]);
disp(['SeongL: ', num2str(x_values(5))]);


% Define the fitting function
f = @(x,tau,v,T_day) real(100 * (1 - (1/sqrt(2)) * (integral(@(z) exp(-(z.^2)/2), -Inf, ...
    (double(real((exp(-(v(2)*x-(v(4)*(30*tau-T_day)).^v(6))) - v(1))/(v(5))))), 'ArrayValued', true))));
%30->to convert months into days

% Plotting
hold on
x_points = linspace(0, 90, 91);

% tau = 1year
tau = 365; 
y_points = zeros(size(x_points));
for i = 1:length(x_points)
    y_points(i) = f(x_points(i),tau,v,T_day_mean);
end

%curve  
plot(x_points, y_points, '--', 'LineWidth', 2, 'Color', '#FE0100','DisplayName', 'tau=1year')

% tau = 2years
tau = 730; 
y_points = zeros(size(x_points));
for i = 1:length(x_points)
    y_points(i) = f(x_points(i),tau,v,T_day_mean);
end


%curve  
plot(x_points, y_points, '--', 'LineWidth', 2, 'Color', '#0000F7','DisplayName', 'tau=2years')

% tau = 3years
tau = 1095; 
y_points = zeros(size(x_points));
for i = 1:length(x_points)
    y_points(i) = f(x_points(i),tau,v,T_day_mean);
end


%curve  
plot(x_points, y_points, '--', 'LineWidth', 2, 'Color', '#FD04FC','DisplayName', 'tau=3years')

% tau = 4years
tau = 1460; 
y_points = zeros(size(x_points));
for i = 1:length(x_points)
    y_points(i) = f(x_points(i),tau,v,T_day_mean);
end


%curve  
plot(x_points, y_points, '--', 'LineWidth', 2, 'Color', '#000000','DisplayName', 'tau=4years')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Biologically effective dose (Gy)')
ylabel('Survival Rate (%)-SR')
title('BED')

%saving the plot
%saveas(gcf, 'BED.pdf')

