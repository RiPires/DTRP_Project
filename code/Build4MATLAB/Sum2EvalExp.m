%%%   Define function "Sum2Eval" to evaluate the sum of the
%%%   residuals between the input data and the calculated.
%%%
%%%   "Variables" is a vector of the free parameters in the 
%%%   model to be fitted (in these case, an exponential with
%%%   parameters "A" and "lambda").
%%%   "TimeData" and "yData" are the input data for the
%%%   optimization.

function Sum2EvalExp = sseval(Variables, TimeData, yData)
A = Variables(1);
lambda = Variables(2);
Sum2EvalExp = sum((yData - A*exp(-lambda * TimeData)).^2);