clc;clear;

tauValues = {0, 0, 0, 0};  % Use cell array to store mixed data types
replacementArray = [1, 2, 3, 4];
condition = true;

indexToReplace = find(cellfun(@(x) x == 0, tauValues) & condition, 1);

if ~isempty(indexToReplace)
    tauValues{indexToReplace} = replacementArray;
end



disp('tau values:');
disp(tauValues);