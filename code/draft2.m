clc;
clearvars; % Clear workspace variables

alpha_beta = 14.4153;
gamma = 0.0056126;
beta = 0.000692;

x_points = linspace(0, 90, 91);
for i = 1:length(x_points)
    T_day = t_bed(alpha_beta,gamma,beta,x_points(i));
    disp('T:');
    disp(T_day);
end    


% T in function of BED
function T_BED = t_bed(alpha_beta,gamma,beta,BED)
    numerator = 7*alpha_beta*BED - 20*alpha_beta - 40;
    denominator = 10*alpha_beta + 20 - 7*(gamma/beta);
    T_BED = numerator/denominator;
end