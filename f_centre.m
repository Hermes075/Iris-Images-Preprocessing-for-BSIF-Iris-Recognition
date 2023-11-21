% Arthur Rubio, Lucas Riviere, 11/2023
% "Preprocessing of Iris Images for BSIF-Based Biometric Systems:
% Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line), 2023, Paris, France.
%
% Finds the iris center in an image by detecting peripheral points and calculating iris diameters 
% in horizontal and vertical directions. It returns the coordinates and diameter of the iris center. 
% Specifically designed for squareCircle.m compatibility.
%
% Input: image I
% Output: coordinates x0,y0 of the iris center and diameter diam

function [x0,y0,diam] = f_centre(I)

s = size(I) ;
e = 2 ;

% Détermination des points périphériques

x0 = round(s(1)/2) ;
y0 = round(s(2)/2) ;
pixel_int_g = 0 ;
pixel_int_d = s(2) ;
pixel_int_up = 0 ;
pixel_int_down = s(1) ;
diam_horizontal = pixel_int_d - pixel_int_g ;
diam_vertical = pixel_int_down - pixel_int_up ;
i=0 ;

while abs(diam_horizontal - diam_vertical) > e
  i = abs(diam_horizontal - diam_vertical)

  % Calcul des bornes intérieures horizontales
  for j = y0:-1:1
    if I(x0,j) == 1
      pixel_int_g = j ;
      break;
    endif
  end

  for j = y0:1:s(2)
    if I(x0,j) == 1
      pixel_int_d = j ;
      break;
    endif
  end

  % Calcul des bornes intérieures verticales
  for i = x0:-1:1
    if I(i,y0) == 1
      pixel_int_up = i ;
      break;
    endif
  end

  for i = x0:1:s(1)
    if I(i,y0) == 1
      pixel_int_down = i ;
      break;
    endif
   end

  % Calcul des diamètres
  diam_horizontal = pixel_int_d - pixel_int_g ;
  diam_vertical = pixel_int_down - pixel_int_up ;

  % Redéfinition des coordonnées du centre
  x0 = pixel_int_up + round(diam_vertical/2) ;
  y0 = pixel_int_g + round(diam_horizontal/2) ;
  endwhile

diam = diam_horizontal ;