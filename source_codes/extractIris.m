% Riviere Lucas & Arthur Rubio - extractIris - 09/11/2023

% Fichier permettant l'isolation de l'iris

clc;                  %Nettoyage de la fenetre de commandes
clear all;            %Suppression des variables
close all;            %Fermeture de toutes les figures
pkg load image ;

% Preparation d'un dossier de stockage des images traitees
nomImage = 'Images/test_iris2.jpg' ;
[chemin, nomSansExtension] = fileparts(nomImage) ;
dossierStockage = 'Images_bmp' ;
nomFichierConverti = [nomSansExtension '.bmp'] ;
cheminAcces = fullfile(dossierStockage, nomFichierConverti) ;

% Chargement de l'image
I = imread(nomImage) ;
I = im2double(I) ;
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(I) ;

figure, imshow(I), title('Image originale') ;

% Rognage de l'image
cote = 2*r_ext + 8 ;             % Marge de 4 pixels de chaque cote
x_min = centre_oeil_x - cote/2 ;
x_max = centre_oeil_x + cote/2 ;
y_min = centre_oeil_y - cote/2 ;
y_max = centre_oeil_y + cote/2 ;

im_rognee = zeros(cote+1,cote+1,3) ;
im_rognee(:,:,:) = I(x_min:x_max,y_min:y_max,:) ;
figure,imshow(im_rognee),title('im rognee');

% On refait les calculs mais cette fois sur l'image rognee
[r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(im_rognee) ;

% Creation d'un filtre pour extraire l'anneau
s = size(im_rognee) ;
filtre = zeros(s(1),s(2)) ;
x_milieu = round(s(1)/2);
y_milieu = round(s(2)/2) ;

for i = 1:s(1)
  for j = 1:s(2)
    filtre(i,j) = (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) >= r_int) && (sqrt((i-x_milieu)**2 + (j-y_milieu)**2) <= r_ext) ;
  end
end

figure, imshow(filtre), title('Filtre utilisé') ;

I_double = im2double(im_rognee) ;

% Extraction de l'iris
iris_extrait = I_double.*filtre ;

figure, imagesc(iris_extrait) , title('la bonne image') ;