% define the file names, d, and N as before
file_names = {'file1.txt', 'file2.txt'};
d = [1, 2];
N = [128, 83];
disp(N(2));

% define the initial parameter values for K, m, and b
v0 = [0.35, 0.35, 1.8];

% define the parameter bounds for K, m, and b
lb = [0, 0, 1];
ub = [1, 1, 3];

% define the fitting function
f = @(x, v, d) v(1) * exp((v(2) * (x - d)) + v(3));

%weights
w1 = 0.5;
w2 = 0.5;

% define the combined chi-square function
chi2 = @(v) w1 .* residuals(file_names{1}, d(1), N(1), v, f) + w2 .* residuals(file_names{2}, d(2), N(2), v, f);

display(w1 .* residuals(file_names{1}, d(1), N(1), v0, f) + ...
    w2 .* residuals(file_names{2}, d(2), N(2), v0, f));

% Set up the genetic algorithm options
%options = optimoptions('ga', 'PopulationSize', 100, 'MaxGenerations', 50);
options = optimoptions('fmincon','MaxIterations',1000,'TolFun',1e-9,'TolX',1e-9);

% Run the genetic algorithm
%v_min = ga(chi2, 3, [], [], [], [], lb, ub, [], options);
v_min = fmincon(chi2, v0, [], [], [], [], lb, ub, [], options);

display(v_min);

% display the results
disp('Values of v that minimize the sum of squares:');
disp(['K: ' num2str(v_min(1))]);
disp(['m: ' num2str(v_min(2))]);
disp(['b: ' num2str(v_min(3))]);

% plot the original data points and the fitted curves
figure;
hold on;
for i = 1:numel(file_names)
    data = load(file_names{i});
    x = data(:, 1);
    y = data(:, 2);
    plot(x, y, '.', 'DisplayName', ['Data ' num2str(i)]);
    
    f_i = @(x) v_min(1) * exp((v_min(2) * (x - d(i))) + v_min(3));
    plot(x, f_i(x), 'DisplayName', ['Fitted curve ' num2str(i)]);

    %f_tp = @(x) 0.2 * exp((0.5 * (x - d(i))) + 2);
    %plot(x, f_tp(x), 'DisplayName', ['New Fitted curve ' num2str(i)]);
    
end
legend('show');
xlabel('x');
ylabel('y');

function r = residuals(file_name, d, N, v, f)
    s = 0;
    data = load(file_name);
    x = data(:, 1);
    y = data(:, 2);
    for i = 1:length(x)
        y_fit = f(x(i), v, d);
        sigma = y(i) .* sqrt(abs((1-y(i)))./N);
        res = (y_fit - y(i)).^2 / sigma.^2;
        s = res + s;
    end
    r = s;
end

