% Arthur Rubio, 04/2024
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2024, Paris, France.
%
% This script executes the unwrapping process for a database of iris images,
% which was given in the paper "Domain-Specific Human-Inspired Binarized
% Statistical Image Features for Iris Recognition", presented at WACV 2019
% by Adam Czajka, Daniel Moreira, Kevin W. Bowyer, and Patrick J. Flynn.
% This script prepares iris images for analysis with the Binarized Statistical
% Image Features (BSIF) method. It unwraps iris images into a format ready
% for feature extraction and comparison.
%
% Input : database of iris pictures
% Output : unwrapped database

clc;
clear all;
close all;
% pkg load image;       % Load image package (only for Octave)

% Local database path
databasePath = 'D:/Prive/Code/BSIF-iris/WACV_2019_Czajka_etal_Stest_images/WACV_2019_Czajka_etal_Stest_images';
filePattern = fullfile(databasePath, '*.tiff');
tiffFiles = dir(filePattern);

% Unwrap all the database
for k = 1:length(tiffFiles)
    baseFileName = tiffFiles(k).name;
    fullFileName = fullfile(databasePath, baseFileName);
    fprintf(1, 'Now unwrapping %s\n', fullFileName);
    squareCircle(fullFileName);
end