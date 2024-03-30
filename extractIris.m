% Arthur Rubio, 04/2024
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2024, Paris, France.
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

function [iris_extrait, r_int, r_ext, centre_oeil_x, centre_oeil_y, cheminAcces, nomSansExtension] = extractIris(nomImage)

% Folder to store the processed images
[chemin, nomSansExtension] = fileparts(nomImage) ;
dossierStockage = 'D:/Prive/Code/BSIF-iris/Unwrapped_DB/DB_bmp' ;
nomFichierConverti = [nomSansExtension '.bmp'] ;
cheminAcces = fullfile(dossierStockage, nomFichierConverti) ;

% Image loading
I = imread(nomImage) ;
s = size(I)
if ndims(I) == 3     % Convert RGB images to gray
    I = rgb2gray(I);
end
I = im2double(I) ;
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(I) ;
% figure, imagesc(I), title('Original image'), colormap gray ;

% Cropping of the image
side_length = 2 * r_ext + 150;
x_min = max(1, round(centre_oeil_x - side_length / 2));
x_max = min(size(I, 2), round(centre_oeil_x + side_length / 2));
y_min = max(1, round(centre_oeil_y - side_length / 2));
y_max = min(size(I, 1), round(centre_oeil_y + side_length / 2));

% Crop the image
im_rognee = I(y_min:y_max, x_min:x_max);
% figure, imagesc(im_rognee), title('Cropped image'), colormap gray ;

% Reconduction of the iris calculations on the cropped image
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(im_rognee) ;

% Creation of a filter to extract the iris ring
s = size(im_rognee) ;
filtre = zeros(s(1),s(2)) ;
x_milieu = round(s(1)/2);
y_milieu = round(s(2)/2) ;
[x, y] = meshgrid(1:s(2), 1:s(1));

% Distance of each pixel to the center (x_center, y_center)
distances = sqrt((x - x_milieu).^2 + (y - y_milieu).^2);
disp(size(r_int));
disp(size(r_ext));
disp(size(distances));

% Creation of the binary mask for pixels inside the ring."
filtre = (distances >= r_int) & (distances <= r_ext);
% figure, imagesc(filtre), title('Filter Used') ;

I_double = im2double(im_rognee) ;
% Extraction of the iris by multiplying the image by the filter
iris_extrait = I_double.*filtre ;
% figure, imagesc(iris_extrait), title('Extracted Iris'), colormap gray ;