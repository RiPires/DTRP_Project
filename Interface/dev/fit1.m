function [K, alpha, beta, gamma, a, Td, delta] = fit1(file_names, labels)

% CSV files
%Liang,Dawson,SeongH,SeongM,SeongL

%file_names = {'Data1.m', 'Data2.m', 'Data3.m', 'Data4.m', 'Data5.m',}

% Data from the files:
%x (tau) - elapsed time in months
%y (SR) - survival rate in percentage

N_values = [128, 35, 83, 51, 24]; %N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]; %T_day - treatment time in days

T_month_values = zeros(size(T_day_values)); %T_month  - treatment time in months
for i = 1:length(T_day_values)
    tm = T_day_values(i)/30;
    T_month_values(i) = tm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%points from all the files%%%
%xx = []; 
%yy = []; 
%for i = 1:length(file_names)
%    data = load(file_names{i});
%    xx = [xx; data(:,1)];
%    yy = [yy; data(:,2)];
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%v - vector with parameters to find   
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 

% Initial parameter values - defined by the user
v0 = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];

    % Define the parameter bounds
    lb = [0, 0, 0, 0, 1000, 0];
    ub = [0.05, 0.05, 0.003, 0.007, 1500, 0.30];
    
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

for i = 1:numel(file_names)
        data = load(file_names{i});
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
            'DisplayName', labels{i})
        
        fit_label = string(strcat('Fit-',labels(i)));
        %fitted function
        add_color = [my_color(1)/(my_color(1)+0.7), my_color(2)/(my_color(2)+0.7), my_color(3)/(my_color(3)+0.7)];
        plot(x_points, f(x_points,v_min,d_values(i),D_values(i),T_day_values(i),T_month_values(i)), ...
            '--', ...
            'LineWidth', 2, ...
            'Color', add_color, ...
            'DisplayName', fit_label,...
            'HandleVisibility', 'on')
 end


%legend,lables and title
legend('Location', 'northeast')
legend('boxoff')
xlabel('Time (months)')
ylabel('SR (%)')
title('Fit 1')

%saving the plot
%saveas(gcf, 'fit1.pdf')

function r = residuals(files, N_list, d_list, D_list, T_day_list, T_month_list, v, f)
    s = 0; %sum for all the points of all the files
    for i = 1:length(files)
        data = load(files{i});
        x = data(:, 1); %x (tau) - elapsed time in months
        y = data(:, 2); %y (SR) - survival rate in percentage
        N = N_list(i);
        d = d_list(i);
        D = D_list(i);
        T_day = T_day_list(i);
        T_month = T_month_list(i);
        sf = 0; %sum for the points of a specific file

        for j = 1:length(x)
            y_fit = f(x(j),v,d,D,T_day,T_month);
            sigma = y(j) .* sqrt(abs((1-y(j)))./N);
            res = (y_fit - y(j)).^2 / sigma.^2;
            sf = res + sf;
        end
        s = sf + s;
    end
    r = s;
end

end %main