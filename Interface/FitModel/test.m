clc, clearvars % clear

% parameters - v
    %v(1) - K 
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - a months^-1
    %v(6) - delta 
v = [0.042, 0.037, 0.002587, 0.00608, 1268, 0.16];

%x (BED) - Biologically effective dose (Gy):
% array with BED values to plot the curves
T_points_days = linspace(1,100,100); %treatment time in days
d = 2; %dose per fraction in Gy/fx
BED_points = []; %BED in Gy
T_points_months = []; %T in months
for i = 1:length(T_points_days)
    n = calculate_n(T_points_days(i)); %n->number of fractions
    D = d * n; %D->dose values in Gy
    B = bed(d,v(2),v(3),D,v(4),T_points_days(i)); %B->BED in Gy 
    BED_points = [BED_points,B];
    t = T_points_days(i)/30;
    T_points_months = [T_points_months,t];
end
%disp('T days'); disp(T_points_days);
%disp('T months'); disp(T_points_months);

SR_points = [];
for j = 1:length(BED_points)
    s = sr(v,BED_points(j),T_points_months(j));
    SR_points = [SR_points,s];
end

disp('T months:'); disp(length(T_points_months));
disp('size BED:'); disp(length(BED_points));
disp('size SR:'); disp(length(SR_points));

plot(BED_points, SR_points, '--', 'LineWidth', 2, 'Color', '#FE0100');

%legend,lables and title
legend('Location', 'northwest')
legend('boxoff')

xlabel('Biologically Effective Dose (Gy) for 1y', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
title('BED','Interpreter','latex')

function result = sr(v,B,T_month)
    result = real(100*exp(-v(1).*exp(-(v(2).*B - (v(5).*(12-T_month)).^v(6)))));
end

% number of fractions in function of the time in days
function n = calculate_n(T)
    if mod(T-1, 7) == 5
        % it is Saturday, so the number of doses is 
        % the same as the one from Friday (1 day ago)
        w = fix((T-1)/7); % number of weeks
        n = (T-1) - (2*w);
    elseif mod(T-2, 7) == 5
        % it is Sunday, so the number of doses is 
        % the same as the one from Friday (2 days ago)
        w = fix((T-2)/7); % number of weeks
        n = (T-2) - (2*w);
    else
        w = fix(T/7); % number of weeks
        n = T - (2*w);
    end
end

% bed function %
function b = bed(d,alpha,beta,D,gamma,T)
    alpha_beta = alpha/beta;
    b = (1+(d/alpha_beta))*D - (gamma*T)/alpha;
end