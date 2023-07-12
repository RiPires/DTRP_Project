clc, clearvars %clear

% CSV files
% Liang,Dawson,SeongH,SeongM,SeongL
file_names = { 'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
%Error Bars of the files points
error_bars_top = {'datafiles/error bars/errorsbars_top_1y.csv',...
    'datafiles/error bars/errorsbars_top_2y.csv',...
    'datafiles/error bars/errorsbars_top_3y.csv',...
    'datafiles/error bars/errorsbars_top_4y.csv'};
error_bars_bot = {'datafiles/error bars/errorsbars_bot_1y.csv',...
    'datafiles/error bars/errorsbars_bot_2y.csv',...
    'datafiles/error bars/errorsbars_bot_3y.csv',...
    'datafiles/error bars/errorsbars_bot_4y.csv'};
number_studies = numel(file_names);
number_years = 4;

% Data from the files:
%sr (SR) - survival rate in percentage
%tau - elapsed time in months

N_values = [128, 35, 83, 51, 24]; %N - number of patients
d_values = [4.88, 1.5, 1.8, 1.8, 1.8]; %d - dose per fraction Gy/fx
D_values = [53.6, 61.5, 55, 45, 32.5]; %D - prescription dose Gy
T_day_values = [28, 42, 37, 37, 37]; %T_day - treatment time in days

%v - vector with parameters obtained from fit2  
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
v = [1.99, 0.0099754, 0.000692, 0.0056126, 0.71, 0.19];


%x (BED) - Biologically effective dose (Gy) and y (SR) - Survival Rate (%):
% we store these points for each year (1,2,3, and 4) accompanied by their
% error bars
points1y = {};
points2y = {};
points3y = {};
points4y = {};
pointsyear = {points1y,points2y,points3y,points4y};

bed_values = zeros(1,number_studies); 
% array to store BED values - needed to plot the error bars of each point
% since they are stored in ascending order of the BED value
for n = 1:number_studies
    bed_values(n) = bed(d_values(n),v(2),v(3),D_values(n),v(4),T_day_values(n));
end
% let's reorder the studies in ascending order of the BED value
[sortedValues, sortedStudies] = sort(bed_values);

% array with the months values for 1,2,3,and 4 years, respectively
months_values = [12,24,36,48];

% for each year, m:
for m = 1:length(months_values)
    month = months_values(m);
    % error bars for that year
    errhigh = load(error_bars_top{m});
    errlow = load(error_bars_bot{m});

    dif_index = 0; % difference between the index used to scroll 
    % through the error bars files and the one used to scroll through
    % the bed values

    % for each study, s:
    for s = 1:number_studies %s - index to scroll through the values
        study = sortedStudies(s); % study - index to scroll through the studies
        data = load(file_names{study});
        tau = data(:,1); % tau (months)
        sr = data(:,2); % survival rate (%)

        err = s - dif_index; % err - index to scroll through the error bars

        t = 1; %index to scroll through tau
        % we start by assuming there is not a tau that corresponds 
        % to the year in question, m
        found_tau = false;
        while t <= length(tau) && found_tau == false
            if abs(month-tau(t))<2 
                found_tau = true; %there is a tau that corresponds to the year in question
                sr_val = sr(t); %respective SR (%)
                bed_val = sortedValues(s); %respective BED (Gy)
                pointsyear{m} = vertcat(pointsyear{m}, [bed_val,sr_val,errhigh(err),errlow(err)]);
            end
        t = t + 1;
        end

        if found_tau == false 
        % if it was not found a tau that corresponds to the year in question in the file of the study
        % the index we are using on the files of the error bars (err) mantains its value 
            dif_index = dif_index + 1;
        end
    end
end
   

%x (BED) - Biologically effective dose (Gy):
% array with BED values to plot the curves
T_points = linspace(1,100,100); %treatment time in days
d = 2; %dose per fraction in Gy/fx
BED_points = []; %BED in Gy
for i = 1:length(T_points)
    n = calculate_n(T_points(i)); %n->number of fractions
    D = d * n; %D->dose values in Gy
    B = bed(d,v(2),v(3),D,v(4),T_points(i)); %B->BED in Gy 
    BED_points = [BED_points,B];
end


% Plotting
tau_values = {365,730,1095,1460};
colors = {'#FE0100','#0000F7','#FD04FC','#000000'};
years_label = {'\tau = 1y', '\tau = 2y', '\tau = 3y', '\tau = 4y'};
markers = {'s','v','v','o'};

hold on

% for each year
for i = 1:number_years
    points = pointsyear{i}; % points for that year
    tau = tau_values{i};
    % plotting the curve:
    sr_plot = [];
    bed_plot = [];
    for j = 1:length(BED_points)
        sr = perform_fit(BED_points(j),tau,v,T_points(j)); 
        if ~isnan(sr)
            b = BED_points(j);
            sr_plot = [sr_plot, sr];
            bed_plot = [bed_plot, b];
        end
    end
    plot(bed_plot, sr_plot, '--', 'LineWidth', 2, 'Color', colors{i},'DisplayName', years_label{i});
    % plotting the points and their error bars:
    for l = 1:length(points)
        for k = 1:length(points{l})
            x_bed = points{l}(1);
            y_sr = points{l}(2);
            err_high = points{l}(3);
            err_low = points{l}(4);
            plot(x_bed, y_sr, markers{i}, 'LineWidth', 2, 'Color', colors{i},'MarkerSize', 8, 'HandleVisibility', 'off');
            errorbar(x_bed,y_sr,err_low,err_high,'Color',colors{i},'LineStyle','none','HandleVisibility', 'off');

        end
    end   
end


%legend,lables and title
legend('Location', 'northwest')
legend('boxoff')

xlabel('Biologically Effective Dose (Gy)', 'Interpreter', 'latex');
ylabel('Survival Rate - $SR (\%)$', 'Interpreter', 'latex');
title('BED','Interpreter','latex')

%saving the plot
saveas(gcf, './results/BED.pdf')

%%%%%%%%%%%%%%%%%%%%%%%
% Functions %

% fitting function %
function result = perform_fit(BED,tau,v,T_day)
    %v(1) - K50/K0
    %v(2) - alpha Gy^-1
    %v(3) - beta Gy^-2
    %v(4) - gamma days^-1
    %v(5) - sigmak/K0
    %v(6) - delta 
    denominator = v(5);
    p = v(2)*BED - ((v(4) * (tau - T_day)) ^ v(6));
    numerator = exp(-p) - v(1);
    t = numerator / denominator;
    if isreal(t)
        result = 100 * (1/2)*(1-erf(t/sqrt(2))); 
    else
        result = NaN;
    end
end  

% bed function %
function b = bed(d,alpha,beta,D,gamma,T)
    alpha_beta = alpha/beta;
    b = (1+(d/alpha_beta))*D - (gamma*T)/alpha;

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
