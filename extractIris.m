% Arthur Rubio, Lucas Riviere, 11/2023
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2023, Paris, France.
%
% This code allows to extract the iris from an eye image using the Canny method
% Creation of a folder to store the processed images
% The image is first cropped to keep only the eye.
% The Canny method is then applied to the image to detect the edges of the iris
% (Gaussian filter, gradient calculation, hysteresis thresholding)
% The iris is then extracted by multiplying the image by a filter and saved in a folder
%
% Input : nomImage : the name of the image to be processed
% Output : nomFichierConverti : the name of the extracted iris image converted to .bmp format
%         cheminAcces : the path to the extracted iris image
%         im_rognee : the cropped image
%         iris_extrait : the extracted iris
%         filtre : the filter used to extract the iris

clc;                  % Cleaning of the command window
clear all;            % Clearing of all variables
close all;            % Closing all windows
pkg load image ;      % Loading of the image package

% Creation of a folder to store the processed images
nomImage = 'Images/iris3.tiff' ;
[chemin, nomSansExtension] = fileparts(nomImage) ;
dossierStockage = 'Images_bmp' ;
nomFichierConverti = [nomSansExtension '.bmp'] ;
cheminAcces = fullfile(dossierStockage, nomFichierConverti) ;

% Image loading
I = imread(nomImage) ;
if ndims(I) == 3  % Vérifie si l'image est en couleur
    I = rgb2gray(I);  % Convertit seulement les images en couleur
end
I = im2double(I) ;
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(I) ;

figure, imshow(I), title('Original image') ;

% Cropping of the image to keep only the eye
cote = 2*r_ext + 8 ;             % Margin of 4 pixels on each side
x_min = centre_oeil_x - cote/2 ;
x_max = centre_oeil_x + cote/2 ;
y_min = centre_oeil_y - cote/2 ;
y_max = centre_oeil_y + cote/2 ;

im_rognee = zeros(cote+1,cote+1) ;
im_rognee(:,:,:) = I(x_min:x_max,y_min:y_max) ;
figure,imshow(im_rognee),title('Cropped image') ;

% Reconduction of the calculations on the cropped image
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(im_rognee) ;

% Creation of a filter to extract the iris ring
s = size(im_rognee) ;
filtre = zeros(s(1),s(2)) ;
x_milieu = round(s(1)/2);
y_milieu = round(s(2)/2) ;

for i = 1:s(1)
  for j = 1:s(2)
    filtre(i,j) = (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) >= r_int) && (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) <= r_ext) ;
  end
end

figure, imshow(filtre), title('Filter Used') ;

% Conversion of the image to double
I_double = im2double(im_rognee) ;

% Extraction of the iris by multiplying the image by the filter
iris_extrait = I_double.*filtre ;
figure, imagesc(iris_extrait), title('Extracted Iris'), colormap gray ;
