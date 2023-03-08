% Define the two matrices to be added
disp(rand(1000));
A = rand(10000);
B = rand(10000);

% Initialize the result matrix
C = zeros(10000);

% Set the number of threads to use
n_threads = 1;

% Split the rows of the matrices among the threads
rows_per_thread = floor(size(A, 1) / n_threads);
row_indices = 1:rows_per_thread:size(A, 1);

% Perform the matrix addition using multithreading
tic %Starts clock
parfor (i = 1:size(A, 1), n_threads)
    C(i, :) = A(i, :) + B(i, :);
end
toc %Stops clock

% Check the result
if isequal(C, A+B)
    disp("Matrix addition succeeded!");
    %disp("C = ");
    %disp(C);
else
    disp("Matrix addition failed!");
    disp("A + B = ");
    disp(A+B);
    disp("C = ");
    disp(C);
end
