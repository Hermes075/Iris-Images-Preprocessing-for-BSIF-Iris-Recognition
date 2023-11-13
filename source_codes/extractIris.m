% Rivière Lucas & Arthur Rubio - Extract Iris - 09/11/2023

clc;                  %Nettoyage de la fenêtre de commandes
clear all;           %Suppression des variables
close all;            %Fermeture de toutes les figures
pkg load image ;

% Chargement de l'image
I = imread('Iris_entier.png') ;

%Affichage
%figure, imshow(I)

% Définition des masques
Mx = [ -1 0 1 ; -1 0 1 ; -1 0 1] ;
My = [1 1 1 ; 0 0 0 ; -1 -1 -1] ;

% Isolation des canaux
R = I(:,:,1) ;
V = I(:,:,2) ;
B = I(:,:,3) ;


% Calcul des dérivées
Rx = filter2(Mx,R)/6 ;
Ry = filter2(My,R)/6 ;

Vx = filter2(Mx,V)/6 ;
Vy = filter2(My,V)/6 ;

Bx = filter2(Mx,B)/6 ;
By = filter2(My,B)/6 ;

% Définition des éléments à utiliser dans la formule

Ix2 = Rx.^2 + Vx.^2 + Bx.^2 ;
IxIy = Rx.*Ry + Vx.*Vy + Bx.*By ;
Iy2 = Ry.^2 + Vy.^2 + By.^2 ;


% Création des contours
Icol = sqrt(0.5*(Ix2 + Iy2 + sqrt((Ix2 - Iy2).^2 + (2*IxIy).^2))) ;

%figure, imagesc(Icol), colormap(gray), title('contour iris') ;

Icol_bin = Icol>50 ;

%figure, imagesc(Icol_bin), colormap(gray), title('contour iris') ;

s=size(Icol_bin) ;

x_milieu = round(s(1)/2) ;
y_milieu = round(s(2)/2) ;
centre_oeil_x = round(s(1)/2) ;
centre_oeil_y = round(s(2)/2) ;
pixel_int_g = 0 ;
pixel_int_d = 0 ;
pixel_ext_g = 0 ;
pixel_ext_d = 0 ;

% Calcul des bornes intérieures horizontales
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

% Calcul des bornes intérieures verticales
for i = x_milieu:-1:1
  if Icol_bin(i, y_milieu) == 1
    pixel_sup = i;
    break;
  end
end

for i = x_milieu:1:s(1)
  if Icol_bin(i, y_milieu) == 1
    pixel_inf = i;
    break;
  end
end

%Diamètre intérieur de l'iris
diam_int = pixel_int_d - pixel_int_g ;

% Calcul du nouveau centre de l'oeil
centre_oeil_x = (pixel_int_g + pixel_int_d) / 2;
centre_oeil_y = (pixel_sup + pixel_inf) / 2;

% Calcul des bornes extérieures horizontales
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

I2 = im2double(I) ;
iris_extrait = zeros(s(1),s(2),3) ;

%iris_extrait(:,:,1) = I2(:,:,1).*filtre ;
%iris_extrait(:,:,2) = I2(:,:,2).*filtre;
%iris_extrait(:,:,3) = I2(:,:,3).*filtre;

%figure, imagesc(iris_extrait) ;


% Test sur une autre image

im = imread('test_iris2.jpg') ;
figure, imshow(im) ;
G = fspecial("gaussian",25,5) ;
im(:,:,1) = conv2(im(:,:,1),G,"same") ;
im(:,:,2) = conv2(im(:,:,2),G,"same") ;
im(:,:,3) = conv2(im(:,:,3),G,"same") ;
figure, imshow(uint8(im)) ;

% Isolation des canaux
R = im(:,:,1) ;
V = im(:,:,2) ;
B = im(:,:,3) ;


% Calcul des dérivées
Rx = filter2(Mx,R)/6 ;
Ry = filter2(My,R)/6 ;

Vx = filter2(Mx,V)/6 ;
Vy = filter2(My,V)/6 ;

Bx = filter2(Mx,B)/6 ;
By = filter2(My,B)/6 ;

% Définition des éléments à utiliser dans la formule

Ix2 = Rx.^2 + Vx.^2 + Bx.^2 ;
IxIy = Rx.*Ry + Vx.*Vy + Bx.*By ;
Iy2 = Ry.^2 + Vy.^2 + By.^2 ;


% Création des contours
imcol = sqrt(0.5*(Ix2 + Iy2 + sqrt((Ix2 - Iy2).^2 + (2*IxIy).^2))) ;

%figure, imagesc(imcol), colormap(gray), title('contour iris') ;
imcol = f_no
im_bin = imcol>0.8 ;

figure, imagesc(im_bin), colormap(gray), title('contour iris') ;