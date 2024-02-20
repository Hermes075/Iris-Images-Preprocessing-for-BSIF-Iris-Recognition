% Assuming extractIris is a function that extracts necessary parameters
% and returns them along with the read image.

clc;                  % Clear command window.
clear all;            % Remove items from workspace, freeing up system memory
close all;            % Close all figures
% pkg load image;       % Load image package (only for Octave)

% Define the path to your database
% ORIGINAL DB PATH
% databasePath = 'D:/Prive/Code/BSIF-iris/WACV_2019_Czajka_etal_Stest_images/WACV_2019_Czajka_etal_Stest_images';

% TEST DB PATH
databasePath = 'D:/Prive/Code/BSIF-iris/Not_working/Not_working_img';
filePattern = fullfile(databasePath, '*.tiff');
tiffFiles = dir(filePattern);

for k = 1:length(tiffFiles)
    baseFileName = tiffFiles(k).name;
    fullFileName = fullfile(databasePath, baseFileName);
    fprintf(1, 'Now unwrapping %s\n', fullFileName);

    % Now you can call your squareCircle function with the parameters
    squareCircle(fullFileName);
end

% test comment
