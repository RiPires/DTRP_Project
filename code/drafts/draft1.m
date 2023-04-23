x = [0,1,2,3,4];
y = [2,4.5,7,8.5,11];
N = 128;

u0 = 0.08;
u_min = lsqnonlin(@(u) chi_square(u, x, y, N), u0);

func = @(x,u) 2*x + u;
figure
plot(x, y, 'o')
hold on
plot(x, func(x, u_min))
xlabel('x')
ylabel('y')


% Display the results
fprintf('Value of u that minimizes the sum of squares: %f\n', u_min);

function residuals = chi_square(u, x, y, N)
    y_fit = 2*x + u;
    sigma = y .* sqrt((1-y)/N);
    residuals = (y_fit - y) ./ sigma;
end