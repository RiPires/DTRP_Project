function [K50_K0, alpha, beta, gamma, Td, sigmak_K0, delta] = fit2(file_names, DataDetails, Bounds)

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
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 

% Initial parameter values - defined by the user HEAD
%v0 = [2.03, 0.010, 0.000666, 0.00542, 0.65, 0.20];
v0 = cell2mat(Bounds(1,:));

% Define the parameter bounds
%lb = [1.99, 0.009, 0.000647, 0.00495, 0.59, 0.19];
%ub = [2.07, 0.011, 0.000692, 0.00598, 0.71, 0.21];
lb = cell2mat(Bounds(2,:));
ub = cell2mat(Bounds(3,:));


% Fitting function
f = @(x,v,d,D,T_day) fit(x,v,d,D,T_day,'fitting');


% Chi-square function
chi2 = @(v) residuals(file_names, N_values, d_values, D_values, T_day_values, v, f);


%fmincon
% Set up the algorithm options
options = optimoptions('fmincon', ...
                       'MaxIterations',1000, ...
                       'TolFun',1e-9,'TolX',1e-9);
% Run the algorithm
[v_min,fval,exitflag,output,lambda,grad,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% Display the results
K50_K0 = num2str(v_min(1));
alpha = num2str(v_min(2));
beta = num2str(v_min(3));
gamma = num2str(v_min(4));
sigmak_K0 = num2str(v_min(5));
Td = num2str(log(2) ./ v_min(4));
delta = num2str(v_min(6));

disp('Parameters values of that minimize the sum of squares (value):'); 
disp(['K50/K0: ', K50_K0]);
disp(['alpha: ', alpha]);
disp(['beta: ', beta]);
disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
disp(['gamma: ', gamma]);
disp(['Td: ' Td]);
disp(['sigmak/K0: ', sigmak_K0]);
disp(['delta: ', delta]);
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
labels = cell2mat(DataDetails(:,3));

hold on
x_points = linspace(1, 70, 71);

for i = 1:numel(file_names)
        data = load(file_names{i});
        y_plot = [];
        x_plot = [];
        x = data(:, 1);
        y = data(:, 2);

        %original points
        my_color = rand(1,3);
        all_marks = {'o','+','*','x','s','d','^','v','>','<','p','h'};

        plot(x, y, ...
            'LineStyle','none', ...
            'Marker',all_marks{mod(i,12)},...
            'LineWidth', 2, ...
            'Color', my_color, ...
            'MarkerSize', 6, ...    
            'DisplayName', labels(i,:))

        %fitted function
        fit_label = string(strcat('Fit-',labels(i,:)));        
        add_color = [my_color(1)/(my_color(1)+0.7), my_color(2)/(my_color(2)+0.7), my_color(3)/(my_color(3)+0.7)];

        for k = 1:length(x_points)
            sr = fit(x_points(k),v_min,d_values(i),D_values(i),T_day_values(i),'plotting');
            if ~isnan(sr)
                tau = x_points(k);
                y_plot = [y_plot, sr];
                x_plot = [x_plot, tau];
           end
        end
        
        plot(x_plot, y_plot, '--', ...
             'LineWidth', 2, ...
             'Color', add_color, ...
             'HandleVisibility', 'on',...
             'DisplayName',fit_label)
 end

%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Time (months)')
ylabel('SR (%)')
title('Fit 2')

%saving the plot
%saveas(gcf, 'fit2.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
%Functions%

function result = fit(tau,v,d,D,T_day,purpose)
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - be ta Gy^-2
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


end %main