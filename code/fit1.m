
%load data from the CSV files
data = readmatrix('datafiles/all_data_fit1.csv');

%variables
%x->tau (elapsed time)
%y->SR (survival rate)
%T->treatment time in days
%d->dose per fraction
%D->prescription dose
%A->author
    %0-Liang
    %1-Dawson
    %2-SeongH
    %3-SeongM
    %4-SeongL

x = data(:,1);  
y = data(:,2);
T = data(:,3);  
d = data(:,4);
D = data(:,5);  
A = data(:,6);


%function
%f = @(v,x,T,d,D) real(100* exp(-v(1)*exp(-(v(2)*(1+(d/(v(2)/v(3))))*D - v(4)*T - (v(5)*(x-T)).^v(6)))));
f = @(v,x,T,d,D) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T - (v(5).*(x-T)).^v(6)))));
%v - vector with parameters    
    %v(1) - K
    %v(2) - alpha
    %v(3) - beta
    %v(4) - gamma
    %v(5) - a
    %v(6) - delta

%initial parameter values
%v0 = [0.042, 0.037, 0.0026, 0.006, 1268, 0.16];
v0 = [1, 1, 1, 1, 1, 1];

%[fit_result,resnorm,residual,exitflag,output,~,J] = lsqcurvefit(f_Liang, v0, x_Liang, y_Liang);

%fit_result = lsqcurvefit(f,v0,x,y);
f2 = @(v,x) f(v,x,T,d,D);
%fit_result->vector with the new values for the parameters
fit_result = lsqcurvefit(f2, v0, x, y);
display(fit_result);

%covariance matrix of the parameters
%covariance_matrix = (J'*J)^-1 * resnorm/(length(y_Liang)-length(fit));

%standard deviation of each parameter
%std_deviation = sqrt(diag(covariance_matrix));

%parameter values and uncertainties
%disp('parameters:');
%disp('K:');
%disp(fit_result(1));
%disp('alpha:');
%disp(fit_result(2));
%disp('beta:');
%disp(fit_result(3));
%disp('gamma:');
%disp(fit_result(4));
%disp('delta:');
%disp(fit_result(5));

%store the values in different lists according to the authors
Liang_data_x = [];
Dawson_data_x = [];
SeongH_data_x = [];
SeongM_data_x = [];
SeongL_data_x = [];

Liang_data_y = [];
Dawson_data_y = [];
SeongH_data_y = [];
SeongM_data_y = [];
SeongL_data_y = [];

Liang_fit = [];
Dawson_fit = [];
SeongH_fit = [];
SeongM_fit = [];
SeongL_fit = [];

for i = 1:length(A)
    if A(i) == 0
        Liang_data_x(end+1) = x(i);
        Liang_data_y(end+1) = y(i);
        Liang_fit(end+1) = f(fit_result,x(i),T(i),d(i),D(i));
    elseif A(i) == 1
        Dawson_data_x(end+1) = x(i);
        Dawson_data_y(end+1) = y(i);
        Dawson_fit(end+1) = f(fit_result,x(i),T(i),d(i),D(i));
    elseif A(i) == 2
        SeongH_data_x(end+1) = x(i);
        SeongH_data_y(end+1) = y(i);
        SeongH_fit(end+1) = f(fit_result,x(i),T(i),d(i),D(i));
    elseif A(i) == 3
        SeongM_data_x(end+1) = x(i);
        SeongM_data_y(end+1) = y(i);
        SeongM_fit(end+1) = f(fit_result,x(i),T(i),d(i),D(i));
    elseif A(i) == 4
        SeongL_data_x(end+1) = x(i);
        SeongL_data_y(end+1) = y(i);
        SeongL_fit(end+1) = f(fit_result,x(i),T(i),d(i),D(i));
    end
end

%disp('uncertainties:');
%disp(std_deviation);


%plotting the different points
hold on
plot(Liang_data_x, Liang_data_y, 'v', 'LineWidth', 2, 'Color', '#FD04FC','MarkerSize', 6, 'DisplayName', 'Liang')
plot(Dawson_data_x, Dawson_data_y, 'o', 'LineWidth', 2, 'Color', '#0000F7','MarkerSize', 6, 'DisplayName', 'Dawson')
plot(SeongH_data_x, SeongH_data_y, '^', 'LineWidth', 2, 'Color', '#000000','MarkerSize', 6, 'DisplayName', 'SeongH')
plot(SeongM_data_x, SeongM_data_y, 's', 'LineWidth', 2, 'Color', '#FD6C6D','MarkerSize', 6, 'DisplayName', 'SeongM')
plot(SeongL_data_x, SeongL_data_y, 'o', 'LineWidth', 2, 'Color', '#46FD4B','MarkerSize', 6, 'DisplayName', 'SeongL')

%plotting the different fitting curves
plot(Liang_data_x, Liang_fit, '--', 'LineWidth', 2, 'Color', '#FD04FC','HandleVisibility', 'off')
plot(Dawson_data_x, Dawson_fit, '--', 'LineWidth', 2, 'Color', '#0000F7','HandleVisibility', 'off')
plot(SeongH_data_x, SeongH_fit, '--', 'LineWidth', 2, 'Color', '#000000','HandleVisibility', 'off')
plot(SeongM_data_x, SeongM_fit, '--', 'LineWidth', 2, 'Color', '#FD6C6D','HandleVisibility', 'off')
plot(SeongL_data_x, SeongL_fit, '--', 'LineWidth', 2, 'Color', '#46FD4B','HandleVisibility', 'off')

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('elapsed time from beginning of RT (Month)-tau')
ylabel('Survival Rate (%)-SR')
title('Fit 1')

%saving the plot
%saveas(gcf, 'fit1.pdf')


