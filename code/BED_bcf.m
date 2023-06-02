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
T_day_mean = mean(T_day_values); 
T_month_values = zeros(size(T_day_values)); %T_month  - treatment time in months
for i = 1:length(T_day_values)
    tm = T_day_values(i)/30;
    T_month_values(i) = tm;
end  

v = [1.99, 0.0099754, 14.4153, 0.0056126, 0.71, 0.19];
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


% Plotting
hold on
%x_points = linspace(0, 90, 91); = x_points = 0:90;
BEDvalues=0:90; % VALUE OF BED
% encontrar a relacao entre BED e T_day_mean

% tau = 1year
tau = 365; 
sr = fit(BEDvalues,tau,v,T_day_mean);
% y_plot = [];
% x_plot = [];
% for i = 1:length(x_points)
%     sr = fit(x_points(i),tau,v,T_day_mean); %-> change this!
%     if ~isnan(sr)
%         bed = x_points(i);
%         y_plot = [y_plot, sr];
%         x_plot = [x_plot, bed];
%    end
% end

% curve  
plot(BEDvalues, sr, '--', 'LineWidth', 2, 'Color', 'm','DisplayName', 'tau=1year')

% points
for i =1:5
    x = x_values(i);
    y = fit(x,tau,v,T_day_mean); %-> change this!
    plot(x, y, 's', 'LineWidth', 2, 'Color', 'r',...
        'MarkerSize', 8, 'HandleVisibility', 'off'),hold on
end

% Liang
% x = x_values(1);
% y = fit(x,tau,v,T_day_mean); %-> change this!
% plot(x, y, 's', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')
% % Dawson
% x = x_values(2);
% y = fit(x,tau,v,T_day_mean); %-> change this!
% plot(x, y, 's', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')
% % SeongH
% x = x_values(3);
% y = fit(x,tau,v,T_day_mean); %-> change this!
% plot(x, y, 's', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')
% % SeongM
% x = x_values(4);
% y = fit(x,tau,v,T_day_mean); %-> change this!
% plot(x, y, 's', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')
% % SeongL
% x = x_values(5);
% y = fit(x,tau,v,T_day_mean); %-> change this!
% plot(x, y, 's', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 2years
tau = 730; 
y_plot = [];
x_plot = [];
for i = 1:length(BEDvalues)
    sr = fit(BEDvalues(i),tau,v,T_day_mean); %> change this!
    if ~isnan(sr)
        bed = BEDvalues(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', 'c','DisplayName', 'tau=2years')

% points

% Liang
x = x_values(1);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'r','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'k','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'g','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')

% tau = 3years
tau = 1095;   
y_plot = [];
x_plot = [];
for i = 1:length(BEDvalues)
    sr = fit(BEDvalues(i),tau,v,T_day_mean); %-> change this!
    if ~isnan(sr)
        bed = BEDvalues(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', 'g','DisplayName', 'tau=3years')


% points

% Liang
x = x_values(1);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'v', 'LineWidth', 2, 'Color', 'm','MarkerSize', 8, 'HandleVisibility', 'off')


% tau = 4years
tau = 1460;   
y_plot = [];
x_plot = [];
for i = 1:length(BEDvalues)
    sr = fit(BEDvalues(i),tau,v,T_day_mean); %-> change this!
    if ~isnan(sr)
        bed = BEDvalues(i);
        y_plot = [y_plot, sr];
        x_plot = [x_plot, bed];
   end
end

%curve  
plot(x_plot, y_plot, '--', 'LineWidth', 2, 'Color', 'y','DisplayName', 'tau=4years') 


% points

% Liang
x = x_values(1);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'o', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')
% Dawson
x = x_values(2);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'o', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongH
x = x_values(3);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'o', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongM
x = x_values(4);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'o', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')
% SeongL
x = x_values(5);
y = fit(x,tau,v,T_day_mean); %-> change this!
plot(x, y, 'o', 'LineWidth', 2, 'Color', 'y','MarkerSize', 8, 'HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Biologically effective dose (Gy)')
ylabel('Survival Rate (%)-SR')
title('BED')

%saving the plot
%saveas(gcf, 'BED.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%
function result = fit(BED,tau,v,T_day)
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
        result = 100 * (1/2)*(1-erf(t/sqrt(2)));
    else
        result = NaN;
    end
 end
        
