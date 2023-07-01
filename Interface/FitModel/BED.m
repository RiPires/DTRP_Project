function BED(file_names,DataDetails,FitData,fnumber)
% function BED
% HELP: this function returns the plot(s) of the relation between the BED and the SR
%
% INPUT
% * file_names: names of the study(ies) of the data file(s)
% * DataDetails: values of the constants presents in the fitting function - N,D,d,T:
%    * N - number of patients
%    * D - prescription dose (Gy)
%    * d - dose per fraction (Gy/fx)
%    * T_day - treatment time (days)
% *FitData: vector with parameters obtained from the fit
% *fnumber: number of the fit (1 or 2)
%
%
% OUTPUT
% * plot of BED in function of SR 
%
%
    N_values = cell2mat(DataDetails(:,4));      % N - number of patients
    D_values = cell2mat(DataDetails(:,5));      % D - prescription dose Gy
    d_values = cell2mat(DataDetails(:,6));      % d - dose per fraction Gy/fx
    T_day_values = cell2mat(DataDetails(:,7));  % T_day - treatment time in days


    number_studies = numel(file_names);
    number_years = 4;

    % Data from the files:
    %tau - elapsed time in months (x)
    %sr (SR) - survival rate in percentage (y)

    %v - vector with parameters obtained from fit1 or fit2  
        %v(1) - K50/K0
        %v(2) - alpha Gy^-1
        %v(3) - beta Gy^-2
        %v(4) - alpha/beta Gy
        %v(5) - gamma days^-1
        %v(6) - Td days
        %v(7) - sigmak/K0
        %v(8) - delta 

    %or

        %v(1) - K 
        %v(2) - alpha Gy^-1
        %v(3) - beta Gy^-2
        %v(4) - alpha/beta Gy
        %v(5) - gamma days^-1
        %v(6) - Td days
        %v(7) - a months^-1
        %v(8) - delta 

    v = FitData;


    %x (BED) - Biologically effective dose (Gy) and y (SR) - Survival Rate (%):
    % we store these points for each year (1,2,3, and 4) accompanied by their
    % error bars
    points1y = {};
    points2y = {};
    points3y = {};
    points4y = {};
    pointsyear = {points1y,points2y,points3y,points4y};

    % array with the months values for 1,2,3,and 4 years, respectively
    months_values = [12,24,36,48];

    % for each year, m:
    for m = 1:length(months_values)
        month = months_values(m);

        % for each study, s:
        for s = 1:number_studies 
            data = load(file_names{s});
            tau = data(:,1); % tau (months)
            sr = data(:,2); % survival rate (%)
        
            % t - index to scroll through tau
            for t = 1:size(tau)
                if abs(month-tau(t)) < 2 % if there is a tau thar corresponds to the year in question
                    sr_val = sr(t); % respective SR (%)
                    bed_val = bedfunction(d_values(s),v(2),v(4),D_values(s),v(5),T_day_values(s));

                    if numel(data(1,:))==2
                        errhigh = zeros(numel(tau),1);
                        errlow = zeros(numel(tau),1);
                    elseif numel(data(1,:))==4
                        errhigh = data(:,3);
                        errlow = data(:,4);
                    end
                    %errhigh = data(:,3); % extracting the error bars
                    %errlow = data(:,4); 
                    pointsyear{m} = vertcat(pointsyear{m}, [bed_val,sr_val,errhigh(t),errlow(t)]);
                end
            end
        end
    end
    

    %x (BED) - Biologically effective dose (Gy):
    % array with BED values to plot the curves
    T_points_days = linspace(1,100,100); %treatment time in days
    T_points_months = [] %treatment time in months
    d = 2; %dose per fraction in Gy/fx
    BED_points = []; %BED in Gy
    for i = 1:length(T_points_days)
        n = calculate_n(T_points_days(i)); %n->number of fractions
        D = d * n; %D->dose values in Gy
        B = bedfunction(d,v(2),v(4),D,v(5),T_points_days(i)); %B->BED in Gy 
        BED_points = [BED_points,B];
        t = T_points_days(i)/30; % time in months
        T_points_months = [T_points_months,t];
    end


    % Plotting
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tau_values_days = {365,730,1095,1460}; % for fit 2, where T is in days
    tau_values_months = {12,24,36,48}; % for fit 1, where T is in moths
    colors = {'#FE0100','#0000F7','#FD04FC','#000000'};
    years_label = {'\tau = 1y', '\tau = 2y', '\tau = 3y', '\tau = 4y'};
    markers = {'s','v','v','o'};

    hold on

    % for each year
    for i = 1:number_years
        points = pointsyear{i}; % points for that year
        tau_day = tau_values_days{i};
        tau_month = tau_values_months{i};
        % plotting the curve:
        sr_plot = [];
        bed_plot = [];
        for j = 1:length(BED_points)
            if fnumber == 1
                sr = fit1bed(BED_points(j),tau_month,v,T_points_months(j)); % fit 1 -> T is in months
            elseif fnumber == 2
                sr = fit2bed(BED_points(j),tau_day,v,T_points_days(j)); % fit 2 -> T is in days
            end

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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

