% Riviere Lucas & Arthur Rubio - extractRayon - 14/11/2023

% Fonction ayant pour but de determiner le rayons interieurs et exterieurs de l'iris par detection de contours
% Ainsi que les coordonnees du centre de l'image (que l'on considere pour l'instant ccomme celui de l'oeil)

function [r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(I)

s = size(I) ;

% Lissage de l'image
G = fspecial("gaussian",25,5) ;
I_gauss(:,:,1) = conv2(I(:,:,1),G,"same") ;
I_gauss(:,:,2) = conv2(I(:,:,2),G,"same") ;
I_gauss(:,:,3) = conv2(I(:,:,3),G,"same") ;

% Definition des masques
Mx = [ -1 0 1 ; -1 0 1 ; -1 0 1] ;
My = [1 1 1 ; 0 0 0 ; -1 -1 -1] ;

% Isolation des canaux
R = I_gauss(:,:,1) ;
G = I_gauss(:,:,2) ;
B = I_gauss(:,:,3) ;

% Calcul des derivees
Rx = filter2(Mx,R)/6 ;
Ry = filter2(My,R)/6 ;

Gx = filter2(Mx,G)/6 ;
Gy = filter2(My,G)/6 ;

Bx = filter2(Mx,B)/6 ;
By = filter2(My,B)/6 ;

% Definition des elements a utiliser dans la formule

Ix2 = Rx.^2 + Gx.^2 + Bx.^2 ;
IxIy = Rx.*Ry + Gx.*Gy + Bx.*By ;
Iy2 = Ry.^2 + Gy.^2 + By.^2 ;

% Creation des contours
Icol = sqrt(0.5*(Ix2 + Iy2 + sqrt((Ix2 - Iy2).^2 + (2*IxIy).^2))) ;

%figure, imagesc(Icol), colormap(gray), title('contour iris') ;

% Normalisation
Icol_n = f_normalisation(Icol) ;

% Seuillage (valeur legerement variable selon image utilisee)
Icol_bin = Icol_n > 0.26 ;

%figure, imagesc(Icol_bin), colormap(gray), title('contour iris binaire') ;

%Calcul du diametre de l'iris
x_milieu = round(s(1)/2) ;
y_milieu = round(s(2)/2) ;
centre_oeil_x = round(s(1)/2) ;
centre_oeil_y = round(s(2)/2) ;
pixel_int_g = 0 ;
pixel_int_d = 0 ;
pixel_ext_g = 0 ;
pixel_ext_d = 0 ;

% Calcul des bornes interieures
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

%Diametre interieur de l'iris
diam_int = pixel_int_d - pixel_int_g ;

% Calcul des bornes exterieures (determination des premiers pixels nons nuls a partir du centre)

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

% Calcul du diametre exterieur
diam_ext = pixel_ext_d - pixel_ext_g ;

% Calculer les rayons
r_ext = round(diam_ext/2);  % Rayon exterieur de l'anneau
r_int = round(diam_int/2);  % Rayon interieur de l'anneau