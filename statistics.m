clc;                  % Clear command window.
clear all;            % Remove items from workspace, freeing up system memory
close all;            % Close all figures

% Specify the path to the CSV file
fileCSVTrue = 'WACV_2019_Czajka_etal_Stest_GENUINE.csv';
fileCSVFalse = 'WACV_2019_Czajka_etal_Stest_IMPOSTOR.csv';

% Load both csv files in a Matlab table
CSVTrue = readtable(fileCSVTrue);
CSVFalse = readtable(fileCSVFalse);

% Get the total number of rows in the file
numRowsTrue = size(fileCSVTrue, 1);
numRowsFalse = size(fileCSVFalse, 1);

% Iterate over each row
for i = 2:numRows
    % Access the data of row i
    row = dataTable(i, :);

    % Display the data of the row (for example, display the row)
    disp(row);

    % You can perform other operations on the row here
end
