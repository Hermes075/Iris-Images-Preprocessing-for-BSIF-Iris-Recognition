% Assuming extractIris is a function that extracts necessary parameters
% and returns them along with the read image.

clc;                  % Clear command window.
clear all;            % Remove items from workspace, freeing up system memory
close all;            % Close all figures
pkg load image;       % Load image package

% Define the path to your database
databasePath = 'BDD_test/BDD_tiff';
filePattern = fullfile(databasePath, '*.tiff');
tiffFiles = dir(filePattern);

for k = 1:length(tiffFiles)
    baseFileName = tiffFiles(k).name;
    fullFileName = fullfile(databasePath, baseFileName);
    fprintf(1, 'Now unwrapping %s\n', fullFileName);

    % Now you can call your squareCircle function with the parameters
    squareCircle(fullFileName);
end
