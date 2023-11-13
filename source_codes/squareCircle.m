% Rivière Lucas & Arthur Rubio - Code to square a circle - 13/11/2023

rint = ... % Rayon intérieur (frontière pupille/iris)
longueur_rectangle = round(2 * pi * rint);

%Créations des différentes listes de coordonnées
x1 = zeros(1, longueur_rectangle);
y1 = zeros(1, longueur_rectangle);
x2 = zeros(1, longueur_rectangle);
y2 = zeros(1, longueur_rectangle);

%Spécification des coordonnées des points de la pupille
centre_x = ... % Coordonnée x du centre de l'œil
centre_y = ... % Coordonnée y du centre de l'œil
rext = ... % Rayon extérieur
rint = ... % Rayon intérieur (déjà défini)

%On initialise le vecteur
theta = linspace(0, 2*pi, longueur_rectangle);

%On génère les coordonnées
for i = 1:longueur_rectangle
    x1(i) = centre_x + rint * cos(theta(i));
    y1(i) = centre_y + rint * sin(theta(i));
    x2(i) = centre_x + rext * cos(theta(i));
    y2(i) = centre_y + rext * sin(theta(i));
end

%On détermine les "lignes" du rectangle
image_rect = zeros(rext - rint, longueur_rectangle);
for i = 1:longueur_rectangle
    [ligne_x, ligne_y] = bresenham(x1(i), y1(i), x2(i), y2(i)); % Utilisation de l'algorithme de Bresenham
    ligne_pixels = interp2(image_originale, ligne_x, ligne_y, 'linear');
    image_rect(:, i) = ligne_pixels;
end

%Affichage de l'image
imshow(image_rect, []);