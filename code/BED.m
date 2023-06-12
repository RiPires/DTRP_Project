clc, clearvars %clear

% CSV files
% Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
number_studies = numel(file_names);
% Data from the files:
%y (SR) - survival rate in percentage
%tau - elapsed time in months

N_values = [128, 35, 83, 51, 24]; %N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]; %T_day - treatment time in days

%v - vector with parameters obtained from fit2  
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
% paper values
v = [2.03, 0.010, 0.000667, 0.005415, 0.65, 0.20];
% our values    
% v = [1.99, 0.0099754, 0.000692, 0.0056126, 0.71, 0.19];

%x (BED) - Biologically effective dose (Gy)
x_values = zeros(size(N_values));
for i = 1:length(x_values)
    x_values (i) = bed(d_values(i),v(2),v(3),D_values(i),v(4),T_day_values(i));
end  

disp('BED values:'); 
disp(['Liang: ', num2str(x_values(1))]);
disp(['Dawson: ', num2str(x_values(2))]);
disp(['SeongH: ', num2str(x_values(3))]);
disp(['SeongM: ', num2str(x_values(4))]);
disp(['SeongL: ', num2str(x_values(5))]);


% Plotting
hold on

T_points = linspace(1,100,100); %treatment time in days
d = 2; %dose per fraction in Gy/fx
BED_points = []; %BED in Gy

for i = 1:length(T_points)
    n = calculate_n(T_points(i)); %n->number of fractions
    D = d * n; %D->dose values in Gy
    B = bed(d,v(2),v(3),D,v(4),T_points(i)); %B->BED in Gy 
    BED_points = [BED_points,B];
end

% tau = 1year
tau = 365; 
y_plot = [];
x_plot = [];
for i = 1:length(BED_points)
    sr = fitting(BED_points(i),tau,v,T_points(i)); 
    if ~isnan(sr)
        b = BED_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, b];
   end
end

% curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FE0100','DisplayName', 'tau=1year')

% points

% Liang
x = x_values(1);
T = T_day_values(1);
y = fitting(x,tau,v,T); 
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T = T_day_values(2);
y = fitting(x,tau,v,T);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T = T_day_values(3);
y = fitting(x,tau,v,T);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T = T_day_values(4);
y = fitting(x,tau,v,T);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T = T_day_values(5);
y = fitting(x,tau,v,T);
plot(x, y, 's', 'LineWidth', 2, 'Color', '#FE0100','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 2years
tau = 730; 
y_plot = [];
x_plot = [];
for i = 1:length(BED_points)
    sr = fitting(BED_points(i),tau,v,T_points(i)); 
    if ~isnan(sr)
        b = BED_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, b];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#0000F7','DisplayName', 'tau=2years')

% points

% Liang
x = x_values(1);
T = T_day_values(1);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T = T_day_values(2);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T = T_day_values(3);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T = T_day_values(4);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T = T_day_values(5);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 8, 'HandleVisibility', 'off')

% tau = 3years
tau = 1095;   
y_plot = [];
x_plot = [];
for i = 1:length(BED_points)
    sr = fitting(BED_points(i),tau,v,T_points(i)); 
    if ~isnan(sr)
        b = BED_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, b];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#FD04FC','DisplayName', 'tau=3years')


% points

% Liang
x = x_values(1);
T = T_day_values(1);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T = T_day_values(2);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T = T_day_values(3);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T = T_day_values(4);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T = T_day_values(5);
y = fitting(x,tau,v,T);
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 4years
tau = 1460;   
y_plot = [];
x_plot = [];
for i = 1:length(BED_points)
    sr = fitting(BED_points(i),tau,v,T_points(i)); 
    if ~isnan(sr)
        b = BED_points(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, b];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', '#000000','DisplayName', 'tau=4years') 


% points

% Liang
x = x_values(1);
T = T_day_values(1);
y = fitting(x,tau,v,T);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
T = T_day_values(2);
y = fitting(x,tau,v,T);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
T = T_day_values(3);
y = fitting(x,tau,v,T);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
T = T_day_values(4);
y = fitting(x,tau,v,T);
plot(x, y, 'o', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
T = T_day_values(5);
y = fitting(x,tau,v,T);
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

% fitting function %
function result = fitting(BED,tau,v,T_day)
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
    denominator = v(5);
    p = v(2)*BED - ((v(4) * (tau - T_day)) ^ v(6));
    numerator = exp(-p) - v(1);
    t = numerator / denominator;
    if isreal(t)
        result = 100 * (1/2)*(1-erf(t/sqrt(2))); %% Confirmar esta expressão
    else
        result = NaN;
    end
end  

% bed function %
function b = bed(d,alpha,beta,D,gamma,T)
    alpha_beta = alpha/beta;
    b = (1+(d/alpha_beta))*D - (gamma*T)/alpha;

end

% number of fractions in function of the time in days
function n = calculate_n(T)
    if mod(T-1, 7) == 5
        % it is Saturday, so the number of doses is 
        % the same as the one from Friday (1 day ago)
        w = fix((T-1)/7); % number of weeks
        n = (T-1) - (2*w);
    elseif mod(T-2, 7) == 5
        % it is Sunday, so the number of doses is 
        % the same as the one from Friday (2 days ago)
        w = fix((T-2)/7); % number of weeks
        n = (T-2) - (2*w);
    else
        w = fix(T/7); % number of weeks
        n = T - (2*w);
    end
end
