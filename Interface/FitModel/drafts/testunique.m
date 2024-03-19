clc;
% % Example array with duplicate values
% array_with_duplicates = [1, 2, 2, 3, 4, 4, 5];
% 
% % Remove duplicates
% unique_array = unique(array_with_duplicates);
% 
% % Display the unique array
% disp(unique_array);

months_values = {'6  12  18  24'}; % Example cell array containing a single string

% Split the string into individual numbers
numbers_str = strsplit(months_values{1}); % Extracting the first element of the cell array
numbers = str2double(numbers_str); % Convert strings to double

% Now you can access the individual numbers
for m = 1:length(numbers)
    month = numbers(m);
    disp(month);
end