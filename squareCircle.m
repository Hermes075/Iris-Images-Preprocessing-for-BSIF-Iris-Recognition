% Arthur Rubio, Lucas Riviere, 11/2023
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2023, Paris, France.
%
% This code allows to unwrap the iris of an eye image processed by the Canny algorithm.
% Definition of the rectangle containing the unwrapped iris
% Creation of lists of coordinates to define the rectangle
% Generation of inner and outer perimetric points
% Generation of the "lines" of the rectangle and storage of the resized unwraped iris
% Creation and storage of the mask using the rectangle and double thresholding
%
% Input : iris_extrait.bmp (image processed by the Canny algorithm)
%        r_int (inner radius)
%        r_ext (outer radius)
% Output : iris_rect.bmp (unwrapped iris)
%          iris_rect_mask.bmp (mask of the unwrapped iris)

clc;                  % Clear command window.
clear all;            % Remove items from workspace, freeing up system memory
close all;            % Close all figures
pkg load image;       % Load image package
extractIris;          % Load the image processed by the Canny algorithm

% Redefine the eye radius
rint = r_int ; % Inner radius (pupil/iris boundary)
rext = r_ext ; % Outer radius (iris/sclera boundary)

% Definition of the length of the rectangle containing the unwrapped iris
longueur_rectangle = round(2 * pi * rint);

% Creation of lists of coordinates
x1 = zeros(1, longueur_rectangle);
y1 = zeros(1, longueur_rectangle);
x2 = zeros(1, longueur_rectangle);
y2 = zeros(1, longueur_rectangle);

% Specification of the coordinates of the center of the eye
centre_x = centre_oeil_x % Coordinate x of the center of the eye
centre_y = centre_oeil_y % Coordinate y of the center of the eye

% Initialisation of the angle vector
theta = linspace(0, 2*pi, longueur_rectangle);

% Generation of inner and outer perimetric points
for i = 1:longueur_rectangle
    x1(i) = centre_x + rint * cos(theta(i));
    y1(i) = centre_y + rint * sin(theta(i));
    x2(i) = centre_x + rext * cos(theta(i));
    y2(i) = centre_y + rext * sin(theta(i));
end

% Generation of the "lines" of the rectangle with interpolation
image_rect = zeros(rext - rint, longueur_rectangle);

for i = 1:longueur_rectangle
    numPoints = rext - rint;
    x_line = linspace(x1(i), x2(i), numPoints);
    y_line = linspace(y1(i), y2(i), numPoints);
    ligne_pixels = interp2(rgb2gray(iris_extrait), x_line, y_line, 'linear') ;
    image_rect(:, i) = ligne_pixels;
end

figure, imagesc(image_rect, []), colormap(gray), title('Unwrapped Iris') ;

% New size of the image in order for the BSIF filter to work
nouvelle_taille = [64, 512];

% Usage of imresize function to resize the image
image_rect = imresize(image_rect, nouvelle_taille);
imwrite(image_rect, cheminAcces, 'bmp') ;

% Mask creation
s=size(image_rect) ;
mask = zeros(s(1),s(2));

for i = 1:s(1)
  for j = 1:s(2)
    mask(i,j) = (image_rect(i,j)>0.14) && (image_rect(i,j)<0.65);
  end
end

% Making the mask logical for the BSIF filter to work
mask = logical(mask) ;
figure, imagesc(mask) ,  colormap(gray)  , title('Masque Iris') ;

% Mask storage
nomMask = [nomSansExtension '_mask'];
dossierStockage = 'Masks_bmp' ;
nomFichierConverti = [nomMask '.bmp'] ;
cheminAcces = ['Masks_bmp/' nomMask '.bmp'] ;

imwrite(mask, cheminAcces, 'bmp') ;