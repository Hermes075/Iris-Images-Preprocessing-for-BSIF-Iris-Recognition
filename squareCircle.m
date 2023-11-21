% Rivière Lucas & Arthur Rubio - Code to square a circle - 13/11/2023

clc;                  %Nettoyage de la fenêtre de commandes
clear all;           %Suppression des variables
close all;            %Fermeture de toutes les figures
pkg load image;
extractIris;
%image_originale = rgb2gray(iris_extrait);


%On redéfinit les rayons de l'oeil
rint = r_int ;  % Rayon intérieur (frontière pupille/iris)
rext = r_ext ; % Rayon extérieur (frontière iris/sclère)

longueur_rectangle = round(2 * pi * rint);

%Créations des différentes listes de coordonnées
x1 = zeros(1, longueur_rectangle);
y1 = zeros(1, longueur_rectangle);
x2 = zeros(1, longueur_rectangle);
y2 = zeros(1, longueur_rectangle);

%Spécification des coordonnées des points de la pupille
centre_x = centre_oeil_x % Coordonnée x du centre de l'œil
centre_y = centre_oeil_y % Coordonnée y du centre de l'œil


%On initialise le vecteur

theta = linspace(0, 2*pi, longueur_rectangle);

%On génère les coordonnées des points périphériques intérieurs et extérieurs
for i = 1:longueur_rectangle
    x1(i) = centre_x + rint * cos(theta(i));
    y1(i) = centre_y + rint * sin(theta(i));
    x2(i) = centre_x + rext * cos(theta(i));
    y2(i) = centre_y + rext * sin(theta(i));
end

%étermination des "lignes" du rectangle
% les "lignes" du rectangle
image_rect = zeros(rext - rint, longueur_rectangle);

for i = 1:longueur_rectangle
    numPoints = rext - rint;
    x_line = linspace(x1(i), x2(i), numPoints);
    y_line = linspace(y1(i), y2(i), numPoints);
    ligne_pixels = interp2(rgb2gray(iris_extrait), x_line, y_line, 'linear');
    image_rect(:, i) = ligne_pixels;
end

%Affichage de l'image
figure, imagesc(image_rect, []), colormap(gray), title('Iris déroulé') ;

% Définir la nouvelle taille souhaitée
nouvelle_taille = [64, 512];

% Utiliser la fonction imresize pour redimensionner l'image
image_rect = imresize(image_rect, nouvelle_taille);
imwrite(image_rect, cheminAcces, 'bmp') ;


% Création du masque
s=size(image_rect) ;
mask = zeros(s(1),s(2));

for i = 1:s(1)
  for j = 1:s(2)
    mask(i,j) = (image_rect(i,j)>0.14) && (image_rect(i,j)<0.65);
  end
end

mask = logical(mask) ;
figure, imagesc(mask) ,  colormap(gray)  , title('Masque Iris') ;

% Stockage du masque
nomMask = [nomSansExtension '_mask'];
dossierStockage = 'Masks_bmp' ;
nomFichierConverti = [nomMask '.bmp'] ;
cheminAcces = ['Masks_bmp/' nomMask '.bmp'] ;


imwrite(mask, cheminAcces, 'bmp') ;












