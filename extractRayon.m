% Arthur Rubio, Lucas Riviere, 11/2023
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2023, Paris, France.
%
% This code determines the inner and outer radius of the iris using edge detection
% The edge detection is performed using the Canny method
% Calculate the coordinates of the center of the image (which is considered for the moment as that of the eye)
%
% Input : I : image of the iris
% Output : r_ext : outer radius of the iris
%          r_int : inner radius of the iris
%          centre_oeil_x : x coordinate of the center of the image
%          centre_oeil_y : y coordinate of the center of the image

function [r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(I)

s = size(I) ;

% Smoothing of the image
G = fspecial("gaussian", 25, 5);
I_gauss = conv2(I, G, "same");

% Definition of the masks
Mx = [ -1 0 1 ; -1 0 1 ; -1 0 1] ;
My = [1 1 1 ; 0 0 0 ; -1 -1 -1] ;

% Calculate of the derivatives (convolution with the masks)
Ix = filter2(Mx, I_gauss) / 6;
Iy = filter2(My, I_gauss) / 6;

% Definition of the elements to use in the formula
Ix2 = Ix.^2;
Iy2 = Iy.^2;
IxIy = Ix .* Iy;

% Creation of the edges
Icol = sqrt(0.5 * (Ix2 + Iy2 + sqrt((Ix2 - Iy2).^2 + (2 * IxIy).^2)));

% Normalisation
Icol_n = f_normalisation(Icol) ;

% Thresholding (slightly variable value depending on the image used)
Icol_bin = Icol_n > 0.02 ;
figure,imagesc(Icol_bin),colormap(gray),title("Image binarisee");

% Détecter le rayon interieur
[centers1, radii1, metric1] = imfindcircles(Icol_bin, [20 80], 'ObjectPolarity', 'bright', 'Sensitivity', 0.3);

% Détecter le rayon exterieur
[centers2, radii2, metric2] = imfindcircles(Icol_bin, [120 150], 'ObjectPolarity', 'bright', 'Sensitivity', 0.3);

% Superposer les cercles détectés du premier ensemble de paramètres
viscircles(centers1, radii1, 'EdgeColor', 'b');

% Superposer les cercles détectés du second ensemble de paramètres
viscircles(centers2, radii2, 'EdgeColor', 'r');

% Diameter calculation of the iris
centre_oeil_x = round(s(1)/2) ;
centre_oeil_y = round(s(2)/2) ;

% Radius calculation
r_int = round(radii1);  % Outer radius of the iris
r_ext = round(radii2);  % Inner radius of the iris
