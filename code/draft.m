clc, clearvars %clear


file_names = {'datafiles/SR_EQ1_L.csv','datafiles/SR_EQ1_D.csv',...
    'datafiles/SR_EQ1_SH.csv','datafiles/SR_EQ1_SM.csv','datafiles/SR_EQ1_SL.csv'};
number_studies = numel(file_names);



% cell array to store the samples for each replicate
generated_files = cell(1, number_studies);
for j = 1:number_studies
    % generating a sample for each file
    data_study=load(file_names{j});
    generated_files{j} = sample(data_study);
end

disp(generated_files{2});


% Generates a sample for a given datafile (for bootstraping)
function s = sample(data_file)
    x = data_file(:, 1); % x (tau) - elapsed time in months
    y = data_file(:, 2); % y (SR) - survival rate in percentage
    arrayLength = length(x); % filesize
    arraySample = []; % array to store the new sample
    % The length of the sample is equal to the length of the original file
    for a = 1:arrayLength
        b_value = zeros(1,2); % Each value is an array with values x,y
        Index = randi(arrayLength); % Generate a random index within the range of the array
        b_value(1) = x(Index); % x value of the generated point
        b_value(2) = y(Index); % y value of the generated point
        %arraySample=[arraySample,b_value];
        arraySample = vertcat(arraySample, b_value);
    end
    s = arraySample;
end