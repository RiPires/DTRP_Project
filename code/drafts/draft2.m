
%load data from the CSV files
%data = readmatrix('datafiles/all_data_fit1.csv');
data = readmatrix("datafiles/SR_EQ1_L.csv");

x = data(:,1);  
y = data(:,2);
T_day = 28;     % treatment time in days
T_mon = 28/30;  % tratment time in months
d = 4.88;       % dose per fraction Gy/fx
D = 53.6;       % prescription dose Gy
N = 128;        % number of patients

%v - vector with parameters    
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

v = [0.042, 0.037, 0.002587, 0.00608, 1268]; %v(6)=0.16
%fitting function
f = @(x,delta) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_mon)).^delta))));

delta0 = 0.25;

options = optimoptions('lsqnonlin','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);
delta_min = lsqnonlin(@(delta) chi_square(delta, x, y), delta0,[],[],options);


%delta_min = lsqnonlin(@(delta) chi_square(delta, x, y), delta0);

%plotting the different points
hold on
plot(x, y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 6, 'DisplayName', 'Liang')
plot(x, f(x, delta_min))

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 1')

% Display the results
fprintf('Value of delta that minimizes the sum of squares: %f\n', delta_min);

function residuals = chi_square(delta, x, y)
    v = [0.042, 0.037, 0.002587, 0.00608, 1268]; %v(6)=0.16
    T_day = 28;     % treatment time in days
    T_mon = 28/30;  % tratment time in months
    d = 4.88;       % dose per fraction Gy/fx
    D = 53.6;       % prescription dose Gy
    N = 128;        % number of patients

    y_fit = real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_mon)).^delta))));
    sigma = y .* sqrt((1-y)/N);
    residuals = (y_fit - y) ./ sigma;
end