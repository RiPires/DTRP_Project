function s = sample(data_file)
% function sample
% HELP: this function generates a sample for a given datafile (Bootstrapping)
%
% INPUT
% * T - treatment time (days)
% 
% OUTPUT
% * sample (s): array with values tau and SR
% -------------------------------------------------------------------------
% made by A. Pardal, R. Pires, and R. Santos in 2023
% -------------------------------------------------------------------------

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
        %arraySample = vertcat(arraySample, b_value);
        arraySample = [arraySample; b_value];
    end
    s = arraySample;
end