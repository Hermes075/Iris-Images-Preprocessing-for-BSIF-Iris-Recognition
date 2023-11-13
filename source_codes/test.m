% Arthur Rubio & Lucas Rivière - Test - 13/11/2023

clc;                  %Nettoyage de la fenêtre de commandes
clear all;           %Suppression des variables
close all;            %Fermeture de toutes les figures
pkg load image ;

% Chargement de l'image
I = imread('iris_entier.png') ;
s = size(I) ;

% Lissage de l'image
G = fspecial("gaussian",25,5) ;
I_gauss(:,:,1) = conv2(I(:,:,1),G,"same") ;
I_gauss(:,:,2) = conv2(I(:,:,2),G,"same") ;
I_gauss(:,:,3) = conv2(I(:,:,3),G,"same") ;
figure, imshow(uint8(I_gauss)),title('Image lissée');

%Affichage
figure, imshow(I),title('Image originale') ;

% Définition des masques
Mx = [ -1 0 1 ; -1 0 1 ; -1 0 1] ;
My = [1 1 1 ; 0 0 0 ; -1 -1 -1] ;

% Isolation des canaux
R = I_gauss(:,:,1) ;
G = I_gauss(:,:,2) ;
B = I_gauss(:,:,3) ;

% Calcul des dérivées
Rx = filter2(Mx,R)/6 ;
Ry = filter2(My,R)/6 ;

Gx = filter2(Mx,G)/6 ;
Gy = filter2(My,G)/6 ;

Bx = filter2(Mx,B)/6 ;
By = filter2(My,B)/6 ;

% Définition des éléments à utiliser dans la formule
Ix2 = Rx.^2 + Gx.^2 + Bx.^2 ;
IxIy = Rx.*Ry + Gx.*Gy + Bx.*By ;
Iy2 = Ry.^2 + Gy.^2 + By.^2 ;

% Création des contours
Icol = sqrt(0.5*(Ix2 + Iy2 + sqrt((Ix2 - Iy2).^2 + (2*IxIy).^2))) ;

%figure, imagesc(Icol), colormap(gray), title('contour iris') ;

% Normalisation
Icol_n = f_normalisation(Icol) ;

% Seuillage
Icol_bin = Icol_n > 0.5 ;

%figure, imagesc(Icol_bin), colormap(gray), title('contour iris') ;

%Calcul du diamètre de l'iris
x_milieu = round(s(1)/2) ;
y_milieu = round(s(2)/2) ;
pixel_int_g = 0 ;
pixel_int_d = 0 ;
pixel_ext_g = 0 ;
pixel_ext_d = 0 ;

% Calcul des bornes intérieures
for j = y_milieu:-1:1
  if Icol_bin(x_milieu,j) == 1
    pixel_int_g = j ;
    break;
  endif
end

for j = y_milieu:1:s(2)
  if Icol_bin(x_milieu,j) == 1
    pixel_int_d = j ;
    break;
  endif
end

%Diamètre intérieur de l'iris
diam_int = pixel_int_d - pixel_int_g ;

% Calcul des bornes extérieures

for j = 1:s(2)
  if Icol_bin(x_milieu,j) == 1
    pixel_ext_g = j ;
    break ;
  endif
end

for j = s(2):-1:1
  if Icol_bin(x_milieu,j) == 1
    pixel_ext_d = j ;
    break ;
  endif
  end

% Calcul du diamètre extérieur
diam_ext = pixel_ext_d - pixel_ext_g ;

% Calculer les rayons
r_ext = round(diam_ext/2);  % Rayon extérieur de l'anneau
r_int = round(diam_int/2);  % Rayon intérieur de l'anneau

% Création d'un filtre pour extraire l'anneau
filtre = zeros(s(1),s(2)) ;

for i = 1:s(1)
  for j = 1:s(2)
    filtre(i,j) = (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) >= r_int) && (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) <= r_ext) ;
  end
end

I_double = im2double(I) ;
iris_extrait = I_double.*filtre ;

%figure, imagesc(iris_extrait) ;