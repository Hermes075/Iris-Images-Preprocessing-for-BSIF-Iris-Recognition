% Arthur Rubio, 04/2024
% GNU GENERAL PUBLIC LICENSE
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems: Binary 
% detected edges and Iris Unwrapping", IPOL (Image Processing On Line), 2024, Paris, France.
%
% This script evaluates the effectiveness of the iris unwrapping process by
% analyzing statistical metrics. It utilizes two CSV files, GENUINE.csv for
% pairs of genuine (matching) iris images and IMPOSTOR.csv for pairs of
% impostor (non-matching) iris images, to verify the consistency of matching
% indices post-unwrapping and assess the accuracy of iris recognition algorithms.
% The methodology for generating these CSV files is based on the approach
% outlined in the paper "Domain-Specific Human-Inspired Binarized Statistical
% Image Features for Iris Recognition", presented at WACV 2019 by Adam Czajka,
% Daniel Moreira, Kevin W. Bowyer, and Patrick J. Flynn.
% This evaluation helps in determining the reliability of the unwrapping 
% process in preserving the distinctive features necessary for accurate iris recognition.
%
% Input : l (size of the BSIF filter)
%         n (number of kernels in a set)
%         filters (path to MATLAB file containing the BSIF filters)
%         fileCSVTrue (path to CSV file containing pairs of genuine images)
%         fileCSVFalse (path to CSV file containing pairs of impostor images)
% Output : console (display of the matching scores for each comparison)
%          iris_rect_mask.bmp (mask of the unwrapped iris)
%          StatsTable (summary table containing mean, standard deviation,
%          variance and error% for genuine and impostor comparisons)
%          graph (showing distribution of matching scores)

clc;
clear all;
close all;

%% Load the selected domain-specific filter set
l = 15;     % size of the filer
n = 7;      % number of kernels in a set
filters = ['./iris_sourced_filters/new_bsif_filters_based_on_eyetracker_data/ICAtextureFilters_' num2str(l) 'x' num2str(l) '_' num2str(n) 'bit.mat'];
load(filters);

scoresGenuine = [];
scoresImpostor = [];

% Path to CSV file
% Original path
% fileCSVTrue = 'WACV_2019_Czajka_etal_Stest_GENUINE.csv';
% fileCSVFalse = 'WACV_2019_Czajka_etal_Stest_IMPOSTOR.csv';

% Demo path
fileCSVTrue = './DB_test/Demo_Czajka_etal_Stest_GENUINE.csv';
fileCSVFalse = './DB_test/Demo_Czajka_etal_Stest_IMPOSTOR.csv';
CSVTrue = readtable(fileCSVTrue);
CSVFalse = readtable(fileCSVFalse);

% Get the number of rows in the file
numRowsTrue = size(CSVTrue, 1);
numRowsFalse = size(CSVFalse, 1);

% Iterate over each row in the Genuine Excel
for i = 1:numRowsTrue
    cellTrue1 = string(CSVTrue{i,1});
    cellTrue2 = string(CSVTrue{i,2});

    % Remove .tiff extension from the file names
    cellTrue1 = erase(cellTrue1, ".tiff");
    cellTrue2 = erase(cellTrue2, ".tiff");
    imTrue1 = imread(['./DB_test/DB_bmp/' + cellTrue1 + '.bmp']) + eps;
    imTrue2 = imread(['./DB_test/DB_bmp/' + cellTrue2 + '.bmp']) + eps;
    codesTrue1(:,:,:,i) = extractCode(imTrue1,ICAtextureFilters);
    codesTrue2(:,:,:,i) = extractCode(imTrue2,ICAtextureFilters);
    masksTrue1(:,:,i) = imread(['./DB_test/Masks_bmp/' + cellTrue1 + '_mask.bmp']) + eps;
    masksTrue2(:,:,i) = imread(['./DB_test/Masks_bmp/' + cellTrue2 + '_mask.bmp']) + eps;

    % Use the matchCodes function to get the comparison score
    scoreG = matchCodes(codesTrue1(:,:,:,i),codesTrue2(:,:,:,i),masksTrue1(:,:,i),masksTrue2(:,:,i),l);
    disp(['Genuine comparison score = ' num2str(scoreG)])
    scoresGenuine = [scoresGenuine, scoreG];
end

% Same operation for the Impostor Excel
for i = 1:numRowsFalse
    cellFalse1 = string(CSVFalse{i,1});
    cellFalse2 = string(CSVFalse{i,2});

    cellFalse1 = erase(cellFalse1, ".tiff");
    cellFalse2 = erase(cellFalse2, ".tiff");
    imFalse1 = imread(['./DB_test/DB_bmp/' + cellFalse1 + '.bmp']) + eps;
    imFalse2 = imread(['./DB_test/DB_bmp/' + cellFalse2 + '.bmp']) + eps;
    codesFalse1(:,:,:,i) = extractCode(imFalse1,ICAtextureFilters);
    codesFalse2(:,:,:,i) = extractCode(imFalse2,ICAtextureFilters);
    masksFalse1(:,:,i) = imread(['./DB_test/Masks_bmp/' + cellFalse1 + '_mask.bmp']) + eps;
    masksFalse2(:,:,i) = imread(['./DB_test/Masks_bmp/' + cellFalse2 + '_mask.bmp']) + eps;

    scoreI = matchCodes(codesFalse1(:,:,:,i),codesFalse2(:,:,:,i),masksFalse1(:,:,i),masksFalse2(:,:,i),l);
    disp(['Impostor comparison score = ' num2str(scoreI)])
    scoresImpostor = [scoresImpostor, scoreI];
end

% Calculation of statistics for both scores
meanGenuine = mean(scoresGenuine);
stdDevGenuine = std(scoresGenuine);
varianceGenuine = var(scoresGenuine);

meanImpostor = mean(scoresImpostor);
stdDevImpostor = std(scoresImpostor);
varianceImpostor = var(scoresImpostor);

% Calculation of error % for both scores
errorGenuine = sum(scoresGenuine > 0.385) / numel(scoresGenuine) * 100;
errorImpostor = sum(scoresImpostor < 0.385) / numel(scoresImpostor) * 100;

% Creating the table
Mean = [meanGenuine; meanImpostor];
StandardDeviation = [stdDevGenuine; stdDevImpostor];
Variance = [varianceGenuine; varianceImpostor];
ErrorPercent = [errorGenuine; errorImpostor];
StatsTable = table(Mean, StandardDeviation, Variance, ErrorPercent, 'RowNames', {'Genuine', 'Impostor'});

disp(StatsTable);

% Display the results
figure;
hold on;
xGenuine = 1;
xImpostor = 2;

scatter(xGenuine*ones(size(scoresGenuine)), scoresGenuine, 'b', 'DisplayName', 'Genuine');
scatter(xImpostor*ones(size(scoresImpostor)), scoresImpostor, 'r', 'DisplayName', 'Impostor');

ylabel('Score');
legend('show');
hold off;