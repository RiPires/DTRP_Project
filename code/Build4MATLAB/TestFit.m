%load data from the CSV files
data = readmatrix('datafiles/TestData.csv');

tau = data(:,1); % Enlapsed Time  
SR = data(:,2);  % Survival Rate
T = data(:,3);   % Treatment Time  
d = data(:,4);   % Dose per fraction
D = data(:,5);   % Total prescribed dose
A = data(:,6);   % Autor ID

%%%   Create an auxiliary function "fun", which deppends
%%%   only on the variable "Variables" - the free
%%%   parameters to be fitted in the model
fun = @(Variables)Sum2Eval(Variables, tau, SR);

%%%   Initial parameters guess - random in this case
%Guess = rand(6,1);
Guess = [0.04, 0.04, 0.01, 0.006, 1260., 0,16];

%%%   The fitted parameters are obtained usign
%%%   the "fminsearch" fucntion, applied to the
%%%   previously deffined auxiliary function
%%%   with the correspondent initial guess.
%%%   Same order as they appear in the "Variables" vector
FiitedParameters = fminsearch(fun,Guess)

