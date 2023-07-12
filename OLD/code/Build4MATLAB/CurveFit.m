%%%   Create exponential decay sample data   %%%
%%%    of the form y = A exp(-lambd * t)     %%%
%%%     with A = 40 and lambd = 0.5          %%%
rng default         % Random number generator
TimeData = 0:0.1:10 % values from 0 to 10 in steps of 0.1
yData = 40*exp(-0.5*TimeData) + randn(size(TimeData))

%%%   Create an auxiliary function "fun", which deppends
%%%   only on the variable "Variables" - the free
%%%   parameters to be fitted in the model
fun = @(Variables)Sum2EvalExp(Variables, TimeData, yData);

%%%   Initial parameters guess - random in this case
Guess = rand(2,1);

%%%   The fitted parameters are obtained usign
%%%   the "fminsearch" fucntion, applied to the
%%%   previously deffined auxiliary function
%%%   with the correspondent initial guess.
%%%   Same order as they appear in the "Variables" vector
FiitedParameters = fminsearch(fun,Guess)

