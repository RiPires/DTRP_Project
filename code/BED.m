clc, clearvars %clear

% CSV files
% Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
number_studies = numel(file_names);
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

v = [1.99, 0.0099754, 14.4153, 0.000692, 0.0056126, 0.71, 0.19];

%v - vector with parameters obtained from fit2   
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - alpha/beta Gy
    %v(4) - beta
    %v(5) - gamma days^-1
    %v(6) - sigmak/K0
    %v(7) - delta 

%x (BED) - Biologically effective dose (Gy)
x_values = zeros(size(N_values));
for i = 1:length(x_values)
    bed = (1+(d_values(i)/v(3)))*D_values(i) - (v(5)*T_day_values(i))/v(2);
    x_values(i) = bed;
end  

disp('BED values:'); 
disp(['Liang: ', num2str(x_values(1))]);
disp(['Dawson: ', num2str(x_values(2))]);
disp(['SeongH: ', num2str(x_values(3))]);
disp(['SeongM: ', num2str(x_values(4))]);
disp(['SeongL: ', num2str(x_values(5))]);


% Plotting
hold on
x_points = linspace(0, 90, 91);

% tau = 1year
tau = 365; 
y_plot = [];
x_plot = [];
for i = 1:length(x_points)
    T_day = t_bed(v(3),v(5),v(4),x_points(i));
    disp('x:')
    disp('T');
    disp(T_day);
    sr = fitting(x_points(i),tau,v,T_day); 
    if ~isnan(sr)
        bed = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

% curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FE0100','DisplayName', 'tau=1year')

% points

% Liang
x = x_values(1);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day); 
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 2years
tau = 730; 
y_plot = [];
x_plot = [];
for i = 1:length(x_points)
    T_day = t_bed(v(3),v(5),v(4),x_points(i));
    sr = fitting(x_points(i),tau,v,T_day);
    if ~isnan(sr)
        bed = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#0000F7','DisplayName', 'tau=2years')

% points

% Liang
x = x_values(1);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')

% tau = 3years
tau = 1095;   
y_plot = [];
x_plot = [];
for i = 1:length(x_points)
    T_day = t_bed(v(3),v(5),v(4),x_points(i));
    sr = fitting(x_points(i),tau,v,T_day);
    if ~isnan(sr)
        bed = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FD04FC','DisplayName', 'tau=3years')


% points

% Liang
x = x_values(1);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 4years
tau = 1460;   
y_plot = [];
x_plot = [];
for i = 1:length(x_points)
    T_day = t_bed(v(3),v(5),v(4),x_points(i));
    sr = fitting(x_points(i),tau,v,T_day);
    if ~isnan(sr)
        bed = x_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#000000','DisplayName', 'tau=4years') 


% points

% Liang
x = x_values(1);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T_day = t_bed(v(3),v(5),v(4),x);
y = fitting(x,tau,v,T_day);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Biologically effective dose (Gy)')
ylabel('Survival Rate (%)-SR')
title('BED')

%saving the plot
%saveas(gcf, 'BED.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
% Functions %
function result = fitting(BED,tau,v,T_day)
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - be ta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
    denominator = v(5);
    p = v(2)*BED - ((v(4) * (tau - T_day)) ^ v(6));
    numerator = exp(-p) - v(1);
    t = numerator / denominator;
    if isreal(t)
        result = 100 * (1/2)*(1-erf(t/sqrt(2))); %% Confirmar esta explressão
    else
        result = NaN;
    end
end

% T in function of BED
function T_BED = t_bed(alpha_beta,gamma,beta,BED)
    numerator = 7*alpha_beta*BED - 20*alpha_beta - 40;
    denominator = 10*alpha_beta + 20 - 7*(gamma/beta);
    T_BED = numerator/denominator;
end
        
