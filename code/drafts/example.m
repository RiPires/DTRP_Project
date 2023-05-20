clc, clearvars %clear

xx = [1,2,3,4];
yy = [4.1,5.5,8.5,9.9];

%v - vector with parameters to find   
    %v(1) - a
    %v(2) - b

% Initial parameter values - defined by the user
v0 = [2, 1];

% Define the parameter bounds
lb = [2, 1];
ub = [4, 3];

% Define the fitting function
%f = @(x,v) 2*x + (1/5)*integral(@(z) 2, 2, v(1)+2*v(2));
f = @(x,v) 2*x + (1/5)*integral(@(z) 2*z, 2, v(1)+2*v(2), 'ArrayValued', true);


% Chi-square function
chi2 = @(v) residuals(xx,yy,v,f);

% Set up the algorithm options
options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);

% Run the algorithm
[v_min,fval,exitflag,output,lambda,grad,hessian] = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

% Display the results
disp('Parameters:'); 
disp(['a: ', num2str(v_min(1))]);
disp(['b: ', num2str(v_min(2))]);

function r = residuals(x_list,y_list,v,f)
    N = 4;
    s = 0;
    for i = 1:length(x_list)
        y_fit = f(x_list(i),v);
        sigma = y_list(i) .* sqrt(abs((1-y_list(i)))./N);
        res = (y_fit - y_list(i)).^2 / sigma.^2;
        s = res + s;
    end
    r = s;
end
