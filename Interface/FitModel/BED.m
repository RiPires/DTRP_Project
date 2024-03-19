function BED(file_names,DataDetails,FitData,fnumber,taus, dref)
% function BED
% HELP: this function returns the plot(s) of the relation between the BED
% (Biologically Effective Dose) and the SR (survival rate)
%
% INPUT
% * file_names: names of the study(ies) of the data file(s)
% * DataDetails: values of the constants presents in the fitting function - N,D,d,T:
%    * N - number of patients
%    * D - prescription dose (Gy)
%    * d - dose per fraction (Gy/fx)
%    * T_day - treatment time (days)
% * FitData: vector with parameters obtained from the fit
% * fnumber: number of the fit (1 or 2)
% * taus: list of tau values selected by the user (elapsed time in months)
% * dref: dose per fraction of reference (Gy/fx) - selected by the user. the default value is 2Gy/fx
%
%
% OUTPUT
% * plot of BED in function of SR 
%
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% last update: 16/03/2024
% -------------------------------------------------------------------------

    N_values = cell2mat(DataDetails(:,3));      % N - number of patients
    D_values = cell2mat(DataDetails(:,4));      % D - prescription dose Gy
    d_values = cell2mat(DataDetails(:,5));      % d - dose per fraction Gy/fx
    T_day_values = cell2mat(DataDetails(:,6));  % T_day - treatment time in days

    number_studies = numel(file_names);

    % Data from the files:
    % tau - elapsed time in months (x)
    % sr (SR) - survival rate in percentage (y)

    % v - vector with parameters obtained from fit1 or fit2 
    % fit1: 
        %v(1) - K50/K0
        %v(2) - alpha Gy^-1
        %v(3) - beta Gy^-2
        %v(4) - alpha/beta Gy
        %v(5) - gamma days^-1
        %v(6) - Td days
        %v(7) - sigmak/K0
        %v(8) - delta 

    % fit2:
        %v(1) - K 
        %v(2) - alpha Gy^-1
        %v(3) - beta Gy^-2
        %v(4) - alpha/beta Gy
        %v(5) - gamma days^-1
        %v(6) - Td days
        %v(7) - a months^-1
        %v(8) - delta 

    v = FitData;

	% taus selected by the user
    % Convert each element of taus to a string
    taus_cell = cell(size(taus));

    % for i = 1:numel(taus)
    %     if isnumeric(taus{i})
    %         try
    %             taus_cell{i} = num2str(taus{i});
    %         catch
    %             disp(['Error converting element ', num2str(i), ' to string. Value: ', num2str(taus{i})]);
    %         end
    %     else
    %         disp(['Element ', num2str(i), ' is not numeric. Value: ', num2str(taus{i})]);
    %     end
    % end

    for i = 1:numel(taus)
        if isnumeric(taus{i})
            taus_cell{i} = num2str(taus{i});
        end   
    end
    

    % Use unique function on the converted cell array
    taus_user = unique(taus_cell); % removing duplicate values if needed

    months_values = sort(taus_user); % array with the taus/months values in ascending order
    months_str = strsplit(months_values{1}); % Extracting the first element of the cell array
    months = str2double(months_str); % Convert strings to double

	
    %x (BED) - Biologically effective dose (Gy) and y (SR) - Survival Rate (%):
    % we store these points for each month selected by the user accompanied by their
    % error bars
	pointsmonths = cell(1, length(months)); % array that will contain one array for each month/tau value
                       % filled with the SR and BED values for each point

    % for each month, m:
    for m = 1:length(months)
        month = months(m);
		points_that_month = []; % array where we store the points for that month/tau value

        % for each study, s:
        for s = 1:number_studies 
            data = load(file_names{s});
            tau_data = data(:,1); % tau (months) from the data files
            sr = data(:,2); % survival rate (%)
            % t - index to scroll through the taus from the data files
            for t = 1:size(tau_data)
              
                if abs(month - tau_data(t)) < 1 
				% if there is a tau in the data that corresponds to the tau selected by the user
                    sr_val = sr(t); % respective SR (%)
                    bed_val = bedfunction(d_values(s),v(2),v(4),D_values(s),v(5),T_day_values(s));
                    % bedfunction(d,alpha,alpha_beta,D,gamma,T)

					% extracting the error bars
                    if numel(data(1,:))==2
                        errhigh = zeros(numel(tau),1);
                        errlow = zeros(numel(tau),1);
                    elseif numel(data(1,:))==4
                        errhigh = data(:,3);
                        errlow = data(:,4);
                    end
                 
                    points_that_month = vertcat(points_that_month, [bed_val,sr_val,errhigh(t),errlow(t)]);
                end
            end
        end
        pointsmonths{m} = points_that_month;
		% pointsmonths = vertcat(pointsmonths, points_that_month);
    end


    %x (BED) - Biologically effective dose (Gy):
    % array with BED values to plot the curves
    T_points_days = linspace(1,100,100); %treatment time in days. for fit 2, where T is in days
    T_points_months = []; %treatment time in months. % for fit 1, where T is in moths
    d = dref; %dose per fraction in Gy/fx given by the user
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
	% List of colors
	colors = {'#FF0000' '#00FF00' '#0000FF' '#00FFFF' '#FF00FF' '#FFFF00'...
                    '#000000' '#D95319' '#7E2F8E' '#FFC0CB' '#808080' '#A2142F' '#006400'...
                    '#EDB120' '#A52A2A'};
	% List of markers
	markers = {'o' '+' '*' '.' 'x' '_' '|' 'square' 'diamond' ...
                    '^' 'v' '>' '<' 'pentagram' 'hexagram'};
	
	hold on;

    % for each month
    for i = 1:length(months)
	
		% Get the colors and markers indexes
		color_i = mod(i-1,length(colors))+1;
		marker_i = mod(i-1,length(markers))+1;
		
        points = pointsmonths{i}; % points for that month

		tau_month = months(i); % for fit 1, where T is in moths
        tau_day = months(i) * 30; % for fit 2, where T is in days

        % label
        label = [num2str(tau_month), ' months'];

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
        plot(bed_plot, sr_plot, '--', 'LineWidth', 2, 'Color', colors{color_i},'DisplayName', label);
        % plotting the points and their error bars:
        for l = 1:size(points, 1)
            x_bed = points(l,1);
            y_sr = points(l,2);
            err_high = points(l,3);
            err_low = points(l,4);
            plot(x_bed, y_sr, markers{marker_i}, 'LineWidth', 2, 'Color', colors{color_i},'MarkerSize', 8, 'HandleVisibility', 'off','DisplayName', label);
            errorbar(x_bed,y_sr,err_low,err_high,'Color',colors{color_i},'LineStyle','none','HandleVisibility', 'off');

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

