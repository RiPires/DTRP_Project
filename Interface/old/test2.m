
function test2
    clc;clear
    fig = figure();

    % data = {'a', '1', '<html><font color="white" bgcolor="red">X</font></center></html>';
    %     'b', '2', '<html><font color="white" bgcolor="red">X</font></center></html>'};
    % 
    % % Modify the data to remove the HTML tags and keep only the 'X' symbol
    % data(:, 3) = cellfun(@(str) extractXSymbol(str), data(:, 3), 'UniformOutput', false);


     data = {false, 12, 1, ' ', 'X';
        false, 13, 2, ' ', 'X'};


    % Create the table with data
    u = uitable(fig, 'Data', data, 'ColumnEditable', [true false false true false], ...
        'ColumnWidth', {70 70 70 70 70}, ...
        'ColumnFormat', {'logical' 'numeric' 'numeric' {'red' 'green' 'blue' 'cyan' ...
    'magenta' 'yellow' 'black' 'orange' 'purple' 'pink' 'gray' 'bordeaux' 'dark green' 'dark yellow'} 'char'}, ...
        'ColumnName', {'Select', 'Val1', 'Val2', 'Color', 'Delete'}, ...
        'CellSelectionCallback', @(s, e) deleterow(e)); 
        % s: handle of the uitable object
        % e: event data structure containing 
        % information about the cell selection event
 

       % % "Select All/Unselect All" button
       %  btnSelectUnAll = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Select All', ...
       %  'Position', [20 10 50 20], 'Callback', @toggleSelectAll, ...
       %  'BackgroundColor', '#D95319', 'ForegroundColor', 'white'); 

           % "Select All/Unselect All" button (Moved up)
    btnSelectUnAll = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Select All', ...
        'Position', [20 230 100 30], 'Callback', @toggleSelectAll, ...
        'BackgroundColor', '#D95319', 'ForegroundColor', 'white');

    %--------------------------
    % "Delete Table Row" Button
    %--------------------------
    function deleterow(eventData)
        if isempty(eventData.Indices)
            return;
        end

        numColumns = size(eventData.Source.Data, 2); % number of columns
        if eventData.Indices(2) == numColumns
            qst = 'Are you sure you want to delete the selected data?';
            button = questdlg(qst, 'WARNING DELETE', 'Yes', 'No', 'No');
            if strcmp(button, 'Yes')
                fprintf('Clicked Row %d\n', eventData.Indices(1));
                row = eventData.Indices(1);
                fprintf('row');
                disp(row);
            
                % Get the uitable handle from the eventData
                uitableHandle = eventData.Source;
                fprintf('uitableHandle');
                disp(uitableHandle);

                % Get the current data from the uitable
                data = uitableHandle.Data;
                fprintf('data:');
                % Get the selected color for the row
                selectedColor = data{row, 4}; % Assuming color column is the 4th column
                fprintf('Selected color: %s\n', selectedColor);
                

                % Remove the specified row from the data
                data(row, :) = [];

                % Update the table data
                uitableHandle.Data = data;

                % Set the flag to true to prevent further processing
                deletedRow = true;
            end
        end
    end

  % Callback function for "Select All" button (Toggle behavior)
    function toggleSelectAll(~, ~)
        % Get the uitable handle
        uitableHandle = u;

        % Get the current data from the uitable
        data = get(uitableHandle, 'Data');

        % Check if any checkbox in the "Select" column is true
        selectColumn = cell2mat(data(:, 1));
        if any(selectColumn)
            % If at least one checkbox is true, unselect all rows
            data(:, 1) = {false};
            btnSelectUnAll.String = 'Select All'; % Change button text
        else
            % If all checkboxes are false, select all rows
            data(:, 1) = {true};
            btnSelectUnAll.String = 'Unselect All'; % Change button text
        end

        % Update the table data
        set(uitableHandle, 'Data', data);
    end

    
    
end
 