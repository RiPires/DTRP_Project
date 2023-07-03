function n = calculate_n(T)
% function calculate_n
% HELP: this function returns the number of fractions in function of the time in days
%
% INPUT
% * T - treatment time (days)
% 
%
% OUTPUT
% * number of fractions (n)
%
%

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