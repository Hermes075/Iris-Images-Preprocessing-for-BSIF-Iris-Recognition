clc;                  % Clear command window.
clear all;            % Remove items from workspace, freeing up system memory
close all;            % Close all figures

%% Load the selected domain-specific filter set
l = 15;     % size of the filer
n = 7;      % number of kernels in a set
filters = ['./iris_sourced_filters/new_bsif_filters_based_on_eyetracker_data/ICAtextureFilters_' num2str(l) 'x' num2str(l) '_' num2str(n) 'bit.mat'];
load(filters);

scoresGenuine = [];
scoresImpostor = [];

% Specify the path to the CSV file
fileCSVTrue = 'WACV_2019_Czajka_etal_Stest_GENUINE.csv';
fileCSVFalse = 'WACV_2019_Czajka_etal_Stest_IMPOSTOR.csv';

% Load both csv files in a Matlab table
CSVTrue = readtable(fileCSVTrue);
CSVFalse = readtable(fileCSVFalse);

% Get the total number of rows in the file
numRowsTrue = size(CSVTrue, 1);
numRowsFalse = size(CSVFalse, 1);
nanCounterTrue = 0;
nanCounterFalse = 0;

% Iterate over each row in the Genuine Excel
for i = 2:numRowsTrue
    % Access the data of row i
    cellTrue1 = string(CSVTrue{i,1});
    cellTrue2 = string(CSVTrue{i,2});
    % Remove the .tiff extension from the file names
    cellTrue1 = erase(cellTrue1, ".tiff");
    cellTrue2 = erase(cellTrue2, ".tiff");
    imTrue1 = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/DB_bmp/' + cellTrue1 + '.bmp']);
    imTrue2 = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/DB_bmp/' + cellTrue2 + '.bmp']);
    codesTrue1(:,:,:,i) = extractCode(imTrue1,ICAtextureFilters);
    codesTrue2(:,:,:,i) = extractCode(imTrue2,ICAtextureFilters);
    masksTrue1(:,:,i) = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/Masks_bmp/' + cellTrue1 + '_mask.bmp']);
    masksTrue2(:,:,i) = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/Masks_bmp/' + cellTrue2 + '_mask.bmp']);

    scoreG = matchCodes(codesTrue1(:,:,:,i),codesTrue2(:,:,:,i),masksTrue1(:,:,i),masksTrue2(:,:,i),l);
    disp(['genuine comparison score = ' num2str(scoreG)])
    if isnan(scoreG)
        nanCounterTrue = nanCounterTrue + 1;
    else
        scoresGenuine = [scoresGenuine, scoreG];
    end
end

% Iterate over each row in the Impostor Excel
for i = 2:numRowsFalse
    % Access the data of row i
    cellFalse1 = string(CSVFalse{i,1});
    cellFalse2 = string(CSVFalse{i,2});
    % Remove the .tiff extension from the file names
    cellFalse1 = erase(cellFalse1, ".tiff");
    cellFalse2 = erase(cellFalse2, ".tiff");
    imFalse1 = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/DB_bmp/' + cellFalse1 + '.bmp']);
    imFalse2 = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/DB_bmp/' + cellFalse2 + '.bmp']);
    codesFalse1(:,:,:,i) = extractCode(imFalse1,ICAtextureFilters);
    codesFalse2(:,:,:,i) = extractCode(imFalse2,ICAtextureFilters);
    masksFalse1(:,:,i) = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/Masks_bmp/' + cellFalse1 + '_mask.bmp']);
    masksFalse2(:,:,i) = imread(['D:/Prive/Code/BSIF-iris/Unwrapped_DB/Masks_bmp/' + cellFalse2 + '_mask.bmp']);

    scoreI = matchCodes(codesFalse1(:,:,:,i),codesFalse2(:,:,:,i),masksFalse1(:,:,i),masksFalse2(:,:,i),l);
    disp(['impostor comparison score = ' num2str(scoreI)])
    if isnan(scoreI)
        nanCounterFalse = nanCounterFalse + 1;
    else
        scoresImpostor = [scoresImpostor, scoreI];
    end
end

disp(nanCounterTrue);
disp(nanCounterFalse);

figure; % Ouvre une nouvelle figure
hold on; % Permet de superposer plusieurs graphiques
scatter(1:length(scoresGenuine), scoresGenuine, 'b', 'DisplayName', 'Genuine');
scatter(1:length(scoresImpostor), scoresImpostor, 'r', 'DisplayName', 'Impostor');
xlabel('Index');
ylabel('Score');
legend('show');
title('Répartition des scores Genuine et Impostor');
hold off; % Termine le mode superposition