pkg load optim

%load data from the CSV files
data = dlmread("../datafiles/SR_EQ1_L.csv", "");

x = data(:,1);  
y = data(:,2);
T = 28;         % treatment time in days
d = 4.88;       % dose per fraction
D = 53.6;       % prescription dose
N = 128;        % number of patients

v = [0.042, 0.037, 0.0026, 0.006, 1268];
%fitting function
f = @(x,delta) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T - (v(5).*(x-T)).^delta))));
%f = @(x,delta) (100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T - (v(5).*(x-T)).^delta))));

delta0 = 0.16;
delta_min = lsqnonlin(@(delta) chi_square(delta, x, y, N), delta0);

%plotting the different points
hold on
plot(x, y, 'v', ...
'LineWidth', 2, ...
'Color', 'b', ...
'MarkerSize', 6, ...
'DisplayName', 'Liang')
plot(x, f(x, delta_min))

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 1')

% Display the results
fprintf('Value of delta that minimizes the sum of squares: %f\n', delta_min);

function residuals = chi_square(delta, x, y, N)
    v = [0.042, 0.037, 0.0026, 0.006, 1268];
    T = 28;         
    d = 4.88;       
    D = 53.6; 
    y_fit = real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T - (v(5).*(x-T)).^delta))));
    sigma = y .* sqrt((1-y)/N);
    residuals = (y_fit - y) ./ sigma;
end



