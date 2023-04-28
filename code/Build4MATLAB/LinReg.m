
%%%   Load data from CSV file to lists   %%%
TestData = dlmread('datafiles/TestDataLinReg.csv', "")

channel = TestData(:,1);  
energy = TestData(:,2);

%%%   Basic calculation of linear regression slope and intersept   %%%
format long
%slope = channel\energy; % The operator "\" does the regression

X = [ones(length(channel),1) channel];
InterceptAndSlope = X\energy;
EnergyFit = X * InterceptAndSlope; % this is used to plot the fitting line
%%%   ##########################################################   %%%

%%%   Polinomial regression using function "polyfit"   %%%
Fit = polyfit(channel, energy, 1)            % fit parameters
energyfit = polyval(Fit, channel);           % y values calculated from the fit parameters
EnergyResid = energy - energyfit;            % residuals
SumResid2 = sum(EnergyResid.^2);             % sum the squares of the residuals
SumTotal = (length(energy)-1) * var(energy); % total sum of squares of y
R2 = 1 - SumResid2/SumTotal;             % R square
%%%   ##############################################   %%%

%plotting the different points
hold on
plot(channel, energy, '*', ...     % Experimental points
    'LineWidth', 2, ...
    'Color', '#FD04FC', ...
    'MarkerSize', 6, ...
    'DisplayName', 'Exp.')
plot(channel, EnergyFit, '--', ... % Fitted line
    'LineWidth', 2, ...
    'Color', '#AD54FD', ...
    'MarkerSize', 6, ...
    'DisplayName', 'Fit')
%legend,lables and title
legend('Location', 'northwest')
legend('boxoff')
xlabel('Channel')
ylabel('Energy (keV)')
title('Energy Calibration')

%saving the plot
%saveas(gcf, 'fit.pdf')


