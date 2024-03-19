clc, clear;

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
