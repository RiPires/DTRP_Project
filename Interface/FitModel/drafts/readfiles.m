clc;
% Open the file for reading
fileID = fopen('./Data/Data.m', 'r');

% Initialize data containers
dataSets = {};  % Create a cell array to store sets of data

% Loop to read data
data_entry = [];  % Initialize data entry for the first set
while ~feof(fileID)
    line = fgetl(fileID);
    if isempty(line)  % Empty line separates sets of points
        if ~isempty(data_entry)
            dataSets{end+1} = data_entry;  % Store the current set
            data_entry = [];  % Reset data entry for the next set
        end
        continue;
    end
    
    values = sscanf(line, '%f');  % Read numeric values
    data_point = struct('tau', values(1), 'SR', values(2), 'lower_uncertainty', values(3), ...
                        'upper_uncertainty', values(4), 'N', values(5), 'D', values(6), ...
                        'd', values(7), 'T', values(8));
    data_entry = [data_entry, data_point];  % Append to data entry for the current set
end

if ~isempty(data_entry)
    dataSets{end+1} = data_entry;  % Store the last set if not empty
end

% Close the file
fclose(fileID);

% Print data from each set
for j = 1:length(dataSets)
    fprintf('Set %d:\n', j);
    for i = 1:length(dataSets{j})
        fprintf('Point %d:\n', i);
        fprintf('tau: %.2f\n', dataSets{j}(i).tau);
        fprintf('SR: %.2f\n', dataSets{j}(i).SR);
        fprintf('lower_uncertainty: %.2f\n', dataSets{j}(i).lower_uncertainty);
        fprintf('upper_uncertainty: %.2f\n', dataSets{j}(i).upper_uncertainty);
        fprintf('N: %.2f\n', dataSets{j}(i).N);
        fprintf('D: %.2f\n', dataSets{j}(i).D);
        fprintf('d: %.2f\n', dataSets{j}(i).d);
        fprintf('T: %.2f\n', dataSets{j}(i).T);
    end
    fprintf('\n');
end
