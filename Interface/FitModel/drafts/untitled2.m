clc;

% Create an empty cell array
myCellArray = {};

% Number of elements you want to add
numElements = 5;

% Loop to add elements to the cell array
for i = 1:numElements
    % Generate the element you want to add (for example, random numbers)
    newElement = i+1; % Replace this with your own element generation logic
    
    % Add the element to the cell array
    myCellArray{i} = newElement;
end

% Display the cell array
disp(myCellArray);

% Assuming your list is stored in a cell array called myList
myList = {'0', 'element2', 'element3'};

% Convert elements of myList to numbers
for i = 1:numel(myList)
    myList{i} = str2double(myList{i});
end

% Check if any element in myList is present in myCellArray
isElementPresent = false;
for i = 1:numel(myList)
    if any(cellfun(@(x)isequal(x, myList{i}), myCellArray))
        isElementPresent = true;
        break; % No need to continue checking once we find one matching element
    end
end


% Display the result
if isElementPresent
    disp('At least one element from the list is present in myCellArray.');
else
    disp('None of the elements from the list are present in myCellArray.');
end


