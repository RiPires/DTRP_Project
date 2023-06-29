%%%   Define function "Sum2Eval" to evaluate the sum of the
%%%   residuals between the input data and the calculated.
%%%
%%%   "Variables" is a vector of the free parameters in the 
%%%   model to be fitted.
%%%   "TimeData" and "yData" are the input data for the
%%%   optimization.

function Sum2Eval = sseval(Variables, tau, SR)
K = Variables(1);      %
alpha = Variables(2);  % Gy^-1
beta = Variables(3);   % Gy^-2
gamma = Variables(4);  % day^-1
a = Variables(5);      % mon^-1
delta = Variables(6);  %
d = 4.88;              % Gy/frac
D = 53.6;              % Gy
T = 28.;               % days
Sum2Eval = sum((SR - exp(-K*exp(-(alpha*(1+d*beta/alpha)*D-gamma*T-(a*(tau-T).^delta))))).^2)


