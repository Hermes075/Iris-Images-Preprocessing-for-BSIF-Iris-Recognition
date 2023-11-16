% Arthur Rubio & Riviere Lucas - f_centre - 15/11/2023

function [x0,y0,diam] = f_centre(I)

s = size(I) ;
e = 2 ;

% Determination des points peripheriques
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

  % Calcul des bornes interieures horizontales
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

  % Calcul des bornes interieures verticales
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

  % Calcul des diametres
  diam_horizontal = pixel_int_d - pixel_int_g ;
  diam_vertical = pixel_int_down - pixel_int_up ;

  % Redefinition des coordonnees du centre
  x0 = pixel_int_up + round(diam_vertical/2) ;
  y0 = pixel_int_g + round(diam_horizontal/2) ;
  endwhile

diam = diam_horizontal ;