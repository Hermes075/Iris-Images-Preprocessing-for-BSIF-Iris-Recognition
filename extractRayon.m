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

% noisy_img = f_addSaltPepperNoise(I, 0.05); % Ajouter le bruit

% Smoothing of the image
G = fspecial("gaussian", 25, 5);
I_gauss = conv2(I, G, "same");
% I_gauss_SP = conv2(noisy_img, G, "same");

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

% Creation of an image to store the results of non-maxima suppression
Icol_suppr = zeros(size(Icol));

for i = 2:size(Icol, 1) - 1
    for j = 2:size(Icol, 2) - 1
        % Conversion from radians to degree
        currentAngle = atan2(Iy(i, j), Ix(i, j));
        currentAngle = rad2deg(currentAngle);
        if currentAngle < 0
            currentAngle = currentAngle + 180;
        end
        currentMagnitude = Icol(i, j);
        % Comparison with neighborhood pixels depending on the angle
        if ((0 <= currentAngle < 22.5) || (157.5 <= currentAngle <= 180))
            neighbor1 = Icol(i, j - 1);
            neighbor2 = Icol(i, j + 1);
        elseif (22.5 <= currentAngle < 67.5)
            neighbor1 = Icol(i - 1, j + 1);
            neighbor2 = Icol(i + 1, j - 1);
        elseif (67.5 <= currentAngle < 112.5)
            neighbor1 = Icol(i - 1, j);
            neighbor2 = Icol(i + 1, j);
        elseif (112.5 <= currentAngle < 157.5)
            neighbor1 = Icol(i - 1, j - 1);
            neighbor2 = Icol(i + 1, j + 1);
        end

        % Non-maxima suppression
        if (currentMagnitude >= neighbor1) && (currentMagnitude >= neighbor2)
            Icol_suppr(i, j) = currentMagnitude;
        end
    end
end

% Normalisation
Icol_suppr_n = f_normalisation(Icol_suppr) ;

% Thresholding (slightly variable value depending on the image used)
Icol_bin = Icol_suppr_n > 0.02 ;

% Invert the colors of the binarized image
Icol_bin_inverted = ~Icol_bin;

% Définir la taille de la marge (2 pixels)
taille_marge = 5;

% Obtenir les dimensions de l'image originale
[dimy, dimx] = size(Icol_bin_inverted);

% Calculer les dimensions de la nouvelle image avec la marge
nouvelle_dimy = dimy + 2 * taille_marge;
nouvelle_dimx = dimx + 2 * taille_marge;

% Créer une matrice noire de la nouvelle taille
image_avec_marge = zeros(nouvelle_dimy, nouvelle_dimx);

% Copier l'image originale au centre de la nouvelle matrice
image_avec_marge(taille_marge + 1:taille_marge + dimy, taille_marge + 1:taille_marge + dimx) = Icol_bin_inverted;
% figure,imagesc(image_avec_marge),colormap(gray),title("Inverted binarized image with margin");

% Get the parameters of the circle defining the iris/pupil boundary
[centers1, radii1, metric1] = imfindcircles(Icol_bin, [20 80], 'ObjectPolarity', 'bright', 'Sensitivity', 0.9);

% Get the parameters of the circle defining the iris/sclera boundary
[centers2, radii2, metric2] = imfindcircles(Icol_bin, [100 140], 'ObjectPolarity', 'bright', 'Sensitivity', 0.95);
% figure,imagesc(Icol_bin),colormap(gray),title("found circles")

% Initialisation des listes pour conserver les cercles filtrés
filteredCenters1 = [];
filteredRadii1 = [];
filteredMetric1 = [];
filteredCenters2 = [];
filteredRadii2 = [];
filteredMetric2 = [];

% Tolerance pour la comparaison des centres
tolerance = 10;

% Boucle à travers tous les cercles détectés pour trouver des centres similaires
if ~isempty(centers1) && ~isempty(centers2)
    for i = 1:size(centers1, 1)
        for j = 1:size(centers2, 1)
            if abs(centers1(i,1) - centers2(j,1)) <= tolerance && abs(centers1(i,2) - centers2(j,2)) <= tolerance
                % Ajoute les cercles correspondants aux listes filtrées
                filteredCenters1 = [filteredCenters1; centers1(i,:)];
                filteredRadii1 = [filteredRadii1; radii1(i)];
                filteredMetric1 = [filteredMetric1; metric1(i)];
                filteredCenters2 = [filteredCenters2; centers2(j,:)];
                filteredRadii2 = [filteredRadii2; radii2(j)];
                filteredMetric2 = [filteredMetric2; metric2(j)];
            end
        end
    end
end

centreImageX = round(s(2)/2);
centreImageY = round(s(1)/2);

% Après avoir trouvé tous les cercles
if isempty(filteredCenters1) && ~isempty(centers1)
    distances = sqrt((centers1(:,1) - centreImageX).^2 + (centers1(:,2) - centreImageY).^2);
    [~, closestIndex1] = min(distances);
    filteredCenters1 = centers1(closestIndex1, :);
    filteredRadii1 = radii1(closestIndex1);
    filteredMetric1 = metric1(closestIndex1);
end

if isempty(filteredCenters2) && ~isempty(centers2)
    distances = sqrt((centers2(:,1) - centreImageX).^2 + (centers2(:,2) - centreImageY).^2);
    [~, closestIndex2] = min(distances);
    filteredCenters2 = centers2(closestIndex2, :);
    filteredRadii2 = radii2(closestIndex2);
    filteredMetric2 = metric2(closestIndex2);
end

hold on;
% Vérification et affichage des cercles pour filteredCenters1
if ~isempty(filteredCenters1)
    viscircles(filteredCenters1, filteredRadii1, 'EdgeColor', 'b');
end

% Vérification et affichage des cercles pour filteredCenters2
if ~isempty(filteredCenters2)
    viscircles(filteredCenters2, filteredRadii2, 'EdgeColor', 'r');
end
hold off;

% Diameter calculation of the iris
centre_oeil_x = round(filteredCenters2(1,1));
centre_oeil_y = round(filteredCenters2(1,2));

% Radius calculation
r_int = round(filteredRadii1);  % Outer radius of the iris
r_ext = round(filteredRadii2);  % Inner radius of the iris
