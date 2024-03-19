function [p,up,goodfit] = progressbar(file_names, DataDetails, Bounds)
% function progressbar
% HELP: this function returns a progress bar to indicate to the user
% the state of the fit(s) being made 
%
% INPUT
% none
% * tau: Elapsed time (months)
% * v: vector with fitting parameters
% 
%
% OUTPUT
% * progress bar
% -------------------------------------------------------------------------
% made by A. Pardal in 27.08.2023
% -------------------------------------------------------------------------


% Call your fitting function
hWaitbar = waitbar(0, 'Fitting in Progress...');
draft(hWaitbar); % Pass hWaitbar as an input argument to draft()

function value = draft(hWaitbar) % Add hWaitbar as an input argument
    nIterations = 100; 
    value = 0;
    for i = 1:nIterations
        n = i + 1;
        value = value + n;
        
        % Update progress bar
        progress = i / nIterations;
        waitbar(progress, hWaitbar, sprintf('Fitting in Progress: %d%%', round(progress*100)));
    end
    % Your fitting is complete, close the progress bar
    close(hWaitbar);
end
