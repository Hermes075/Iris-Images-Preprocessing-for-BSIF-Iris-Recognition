% v2 modified by Baptiste Magnier
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

function [r_ext,r_int,centre_oeil_x,centre_oeil_y] = extractRayon(J)

s = size(J);
centreImageX = round(s(2)/2);
centreImageY = round(s(1)/2);
tolerance = 10;

[filteredPupilCenter, filteredPupilRadii, filteredPupilMetric] = deal([], [], []);
[filteredIrisCenter, filteredIrisRadii, filteredIrisMetric] = deal([], [], []);

% Smoothing of the image
G = fspecial("gaussian", 25, 7);
I_gauss = conv2(J, G, "same");
% I_gauss_SP = conv2(noisy_img, G, "same");

% Applying median filtering to the smoothed image to reduce noise while preserving edges
I_median = medfilt2(I_gauss, [3 3]);  % Utilisation d'une fenêtre de 3x3 pour le filtrage médian

% Histogram normalization of the smoothed image
% I_eq = histeq(I_gauss);
% Histogram adjustment of the smoothed image
I_adj = imadjust(I_median);

% Definition of the masks
% SOBEL MASKS
Mx = [-1 0 1; -2 0 2; -1 0 1];
My = [1 2 1; 0 0 0; -1 -2 -1];
% Mx=[-1 0 1;-1 0 1;-1 0 1];
% My=[1 1 1;0 0 0;-1 -1 -1];

% Application des masques de Sobel
Jx = filter2(Mx, I_adj);
Jy = filter2(My, I_adj);
% Jx=filter2(-Mx,I_gauss)/6;
% Jy=filter2(-My,I_gauss)/6;

eta = atan2(Jy, Jx); % Utilisation de atan2 pour gérer correctement les quadrants
Ggray = sqrt(Jx.^2 + Jy.^2);
% eta = atan(Jy./Jx);
% Ggray=sqrt(Jx.*Jx + Jy.*Jy);

% figure,imagesc(J),colormap(gray), title('Image grey');
% figure,imagesc(Ggray),colormap(gray), title('Gradient grey');
% figure,imagesc(eta),colormap(gray), title('Gradient direction');

%%%%%%%%%% non maxima suppression

[NMS] =  directionalNMS(Jx,Jy);
Gradient_max= Ggray .* NMS;
% figure,imagesc(NMS),colormap(gray), title('NMS');

% figure,imagesc(Gradient_max), colormap(gray), title('Gradient max');

% Thresholding (slightly variable value depending on the image used)
Icol_suppr_n = f_normalisation(Gradient_max);
level = adaptthresh(Icol_suppr_n, 'NeighborhoodSize', [25 25], 'ForegroundPolarity', 'dark');
level = level + 0.03; % Augmenter le seuil de 0.3
Icol_bin = imbinarize(Icol_suppr_n, level);
% Icol_bin = Icol_suppr_n > 0.05 ;

% Seuil de circularité
circularityThreshold = 0.01; % Vous pouvez ajuster cette valeur

% Analyse des composantes connectées
CC = bwconncomp(Icol_bin);

% Calculer le nombre de pixels pour chaque composante
numPixels = cellfun(@numel, CC.PixelIdxList);

% Initialiser un vecteur pour les circularités
circularities = zeros(CC.NumObjects, 1);

% Préparation d'une image pour marquer les composantes circulaires
Icol_circular = false(size(Icol_bin));

% Calculer la circularité pour chaque composante
for i = 1:CC.NumObjects
    % Extraire la composante binaire individuelle
    singleComponent = false(size(Icol_bin));
    singleComponent(CC.PixelIdxList{i}) = true;
    
    % Calculer le périmètre de la composante
    componentPerimeter = sum(bwperim(singleComponent, 8), 'all');
    
    % Calculer la circularité de la composante
    area = numPixels(i);
    circularity = (4 * pi * area) / (componentPerimeter ^ 2);
    circularities(i) = circularity;
    
    % Appliquer le seuil de circularité directement
    if circularity > circularityThreshold
        Icol_circular(CC.PixelIdxList{i}) = true;
    end
end

% Fermeture morphologique pour combler les petits trous et connecter les régions disjointes
SE1 = strel('disk', 4); % Crée un élément structurant de forme disque avec un rayon de 2 pixels
% Icol_close = imclose(Icol_bin, SE1); % Réalise la fermeture morphologique
Icol_close = imclose(Icol_circular, SE1); % Réalise la fermeture morphologique
% Icol_close2 = bwmorph(Icol_close1, "skeleton", Inf); % Réalise la fermeture morphologique
% SE2 = strel('line', 5, 0); % Crée un élément structurant de forme disque avec un rayon de 2 pixels
% Icol_close = imdilate(Icol_close2, SE2); % Réalise la fermeture morphologique

[pupilCenter, pupilRadii, pupilMetric] = pupilDetectionDynamicSensitivity(Icol_close, centreImageX, centreImageY);
% Calculate distances between the centers of the circles and the image center
distances = sqrt((pupilCenter(:,1) - centreImageX).^2 + (pupilCenter(:,2) - centreImageY).^2);

% Find the index of the circle closest to the image center
[~, minIndex] = min(distances);

% Select the characteristics of this circle
filteredPupilCenter = pupilCenter(minIndex, :);
filteredPupilRadii = pupilRadii(minIndex);
filteredPupilMetric = pupilMetric(minIndex);

% Dynamic cropping of the image based on the dilatation of the pupil
scale = round(filteredPupilRadii)/60;
Icol_close(1 : round((filteredPupilCenter(2) - (1.3/scale)*filteredPupilRadii)),:) = 0;
Icol_close(round((filteredPupilCenter(2) + (2/scale)*filteredPupilRadii)) : s(1),:) = 0;
Icol_close(:,1 : round((filteredPupilCenter(1) - (3/scale)*filteredPupilRadii))) = 0;
Icol_close(:,round((filteredPupilCenter(1) + (3/scale)*filteredPupilRadii)) : s(2)) = 0;

[irisCenter, irisRadii, irisMetric] = irisDetectionDynamicSensitivity(Icol_close, filteredPupilCenter);
[filteredIrisCenter, filteredIrisRadii, filteredIrisMetric] = filterCircles(irisCenter, irisRadii, irisMetric, centreImageX, centreImageY, tolerance);

% Invert the colors of the binarized image
Icol_close_inverted = ~Icol_close;

% Définir la taille de la marge (2 pixels)
taille_marge = 5;

% Obtenir les dimensions de l'image originale
[dimy, dimx] = size(Icol_close_inverted);

% Calculer les dimensions de la nouvelle image avec la marge
nouvelle_dimy = dimy + 2 * taille_marge;
nouvelle_dimx = dimx + 2 * taille_marge;

% Créer une matrice noire de la nouvelle taille
image_avec_marge = zeros(nouvelle_dimy, nouvelle_dimx);

% Copier l'image originale au centre de la nouvelle matrice
image_avec_marge(taille_marge + 1:taille_marge + dimy, taille_marge + 1:taille_marge + dimx) = Icol_close_inverted;
% figure,imagesc(image_avec_marge),colormap(gray),title("Inverted binarized image with margin");

function [pupilCenter, pupilRadii, pupilMetric] = pupilDetectionDynamicSensitivity(Icol_close, centreImageX, centreImageY)
    sensitivity = 0.859;
    maxSensitivity = 1;
    sensitivityStep = 0.02;
    radiusRange = [20 80];
    objectPolarity = 'bright';
    tolerance = 50;

    while sensitivity <= maxSensitivity
        [centers, radii, metric] = imfindcircles(Icol_close, radiusRange, 'ObjectPolarity', objectPolarity, 'Sensitivity', sensitivity);
        [pupilCenter, pupilRadii, pupilMetric, found] = filterCircles(centers, radii, metric, centreImageX, centreImageY, tolerance);
        if found
            break;
        else
            sensitivity = sensitivity + sensitivityStep;
        end
    end
end

function [irisCenter, irisRadii, irisMetric] = irisDetectionDynamicSensitivity(Icol_close, pupilCenter)
    sensitivity = 0.859;
    maxSensitivity = 1;
    sensitivityStep = 0.02;
    radiusRange = [100 180];
    objectPolarity = 'bright';
    tolerance = 20;

    while sensitivity <= maxSensitivity
        [centers, radii, metric] = imfindcircles(Icol_close, radiusRange, 'ObjectPolarity', objectPolarity, 'Sensitivity', sensitivity);
        [irisCenter, irisRadii, irisMetric, found] = filterCircles(centers, radii, metric, pupilCenter(1), pupilCenter(2), tolerance);
        if found
            break;
        else
            sensitivity = sensitivity + sensitivityStep;
        end
    end
end

    function [filteredCenters, filteredRadii, filteredMetric, found] = filterCircles(centers, radii, metric, centerX, centerY, tolerance)
    filteredCenters = [];
    filteredRadii = [];
    filteredMetric = [];

    found = false;
    if isempty(centers)
        return;
    end

    for i = 1:size(centers, 1)
        if abs(centers(i,1) - centerX) <= tolerance && abs(centers(i,2) - centerY) <= tolerance
            filteredCenters = [filteredCenters; centers(i,:)];
            filteredRadii = [filteredRadii; radii(i)];
            filteredMetric = [filteredMetric; metric(i)];
        end
    end

    if ~isempty(filteredCenters)
        distances = sqrt((filteredCenters(:,1) - centerX).^2 + (filteredCenters(:,2) - centerY).^2);
        [~, closestIndex] = min(distances);
        filteredCenters = filteredCenters(closestIndex, :);
        filteredRadii = filteredRadii(closestIndex);
        filteredMetric = filteredMetric(closestIndex);
        found = true;
    end
end

% figure,imagesc(Icol_close),colormap(gray),title("found circles");

hold on;
% Vérification et affichage des cercles pour filteredPupilCenter
if ~isempty(filteredPupilCenter)
    viscircles(filteredPupilCenter, filteredPupilRadii, 'EdgeColor', 'b');
end

% Vérification et affichage des cercles pour filteredIrisCenter
if ~isempty(filteredIrisCenter)
    viscircles(filteredIrisCenter, filteredIrisRadii, 'EdgeColor', 'r');
end
hold off;

centre_oeil_x = round(filteredPupilCenter(1));
centre_oeil_y = round(filteredPupilCenter(2));

% Diameter calculation of the iris
if isempty(filteredIrisCenter)
    % Gestion de l'absence de détection
    fprintf('Aucun iris détecté.\n');
    filteredIrisRadii = filteredPupilRadii * (2.3/scale);
end

% Radius calculation
r_int = round(filteredPupilRadii);  % Outer radius of the iris
r_ext = round(filteredIrisRadii);  % Inner radius of the iris
end