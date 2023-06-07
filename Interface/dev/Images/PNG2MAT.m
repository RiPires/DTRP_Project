filenames = dir('*.png'); %# get information of all .png files in work dir
n  = numel(filenames);    %# number of .png files

for i = 1:n
    A = imread( filenames(i).name );

    %# gets full path, filename radical and extension
    [fpath, radical, ext] = fileparts( filenames(i).name ); 

    save([radical '.mat'], 'A');                          
end