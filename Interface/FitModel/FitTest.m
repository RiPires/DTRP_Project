function Fit(file_names, N_values, d_values, D_values, T_day_values, guess)

%%%   INPUTS:                      %%%
%%%                                %%%
%%%   OUTPUTS: Fitted parameters   %%%
    
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
    [v_min,fval,exitflag,output,lambda,grad,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

    % Uncertainties
    cm = inv(hessian); %cm -> covariance matrix
    un = zeros(size(v_min)); %un -> vector with uncertainties
    d_cm = diag(cm); %d_cm -> diagonal of the covariance matrix
    for i = 1:length(un)
        un(i) = sqrt(d_cm(i));
    end
    
    % Display the results
    disp('Parameters values of that minimize the sum of squares (value ± std):'); 
    disp(['K: ', num2str(v_min(1)), ' ± ', num2str(un(1))]);
    disp(['alpha: ', num2str(v_min(2)), ' ± ', num2str(un(2))]);
    disp(['beta: ', num2str(v_min(3)), ' ± ', num2str(un(3))]);
    disp(['alpha/beta: ' num2str(v_min(2)./v_min(3))]);
    disp(['gamma: ', num2str(v_min(4)), ' ± ', num2str(un(4))]);
    disp(['a: ', num2str(v_min(5)), ' ± ', num2str(un(5))]);
    disp(['Td: ' num2str(log(2) ./ v_min(4))]);
    disp(['delta: ', num2str(v_min(6)), ' ± ', num2str(un(6))]);

end