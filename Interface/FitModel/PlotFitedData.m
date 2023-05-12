function PlotFitedData(file_names, labels)

    %%%   Fit function
    f = @(x,v,d,D,T_day,T_month) real(100*exp(-v(1).*exp(-(v(2).*(1+(d./(v(2)./v(3)))).*D - v(4).*T_day - (v(5).*(x-T_month)).^v(6)))));

    hold on
    x_points = linspace(0, 70, 71);

    for i = 1:numel(file_names)
        data = load(file_names{i});
        x = data(:, 1);
        y = data(:, 2);
        %original points
        plot(x, y, 'v', ...
        'LineWidth', 2, ...
        'Color', '#FD04FC', ...
        'MarkerSize', 6, ...
        'DisplayName', labels{i})
        %fitted function   
        plot(x_points, f(x_points,v_min,d_values(i),D_values(i),T_day_values(i),T_month_values(i)), '--', ...
            'LineWidth', 2, ...
            'Color', '#FD04FC', ...
            'HandleVisibility', 'off')
    end

end %main