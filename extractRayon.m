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
G = fspecial("gaussian", 125, 3);
I_gauss = conv2(J, G, "same");
% I_gauss_SP = conv2(noisy_img, G, "same");

% Definition of the masks
% SOBEL MASKS
Mx = [-1 0 1; -2 0 2; -1 0 1];
My = [1 2 1; 0 0 0; -1 -2 -1];
% Mx=[-1 0 1;-1 0 1;-1 0 1];
% My=[1 1 1;0 0 0;-1 -1 -1];

% Application des masques de Sobel
Jx = filter2(Mx, I_gauss);
Jy = filter2(My, I_gauss);
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
Icol_bin = Icol_suppr_n > 0.05 ;

[pupilCenter, pupilRadii, pupilMetric] = pupilDetectionDynamicSensitivity(Icol_bin);
[filteredPupilCenter, filteredPupilRadii, filteredPupilMetric] = filterCircleCenters(filteredPupilCenter, filteredPupilRadii, filteredPupilMetric, centreImageX, centreImageY, tolerance);

% Create a grid of coordinates for x and y
[xGrid, yGrid] = meshgrid(1:size(Icol_bin, 2), 1:size(Icol_bin, 1));

% Condition 1: Pixels located between centreImageX - rayonPupille and centreImageX + rayonPupille
conditionX = xGrid >= (filteredPupilCenter(1) - filteredPupilRadii) & xGrid <= (filteredPupilCenter(1) + filteredPupilRadii);

% Condition 2: Pixels located above centreImageY + rayonPupille
conditionY = yGrid <= (filteredPupilCenter(2) + filteredPupilRadii);

% Combine both conditions to identify the pixels to be blackened
pixelsToBlacken = conditionX & conditionY;

% Update Icol_bin to blacken the selected pixels
Icol_bin(pixelsToBlacken) = 0;

[irisCenter, irisRadii, irisMetric] = irisDetectionDynamicSensitivity(Icol_bin);
[filteredIrisCenter, filteredIrisRadii, filteredIrisMetric] = filterCircleCenters(filteredIrisCenter, filteredIrisRadii, filteredIrisMetric, centreImageX, centreImageY, tolerance);

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

function [pupilCenter, pupilRadii, pupilMetric] = pupilDetectionDynamicSensitivity(Icol_bin)
    % Initialiser les paramètres de sensibilité
    initialSensitivity = 0.859;  % Commencez avec une sensibilité plus basse
    maxSensitivity = 1.2;     % Sensibilité maximale à ne pas dépasser
    sensitivityStep = 0.02;    % Incrément de la sensibilité pour chaque itération

    % Détection pour le cercle iris/pupille
    [pupilCenter, pupilRadii, pupilMetric] = tryFindCircles(Icol_bin, [20 80], 'bright', initialSensitivity, maxSensitivity, sensitivityStep);
end

function [irisCenter, irisRadii, irisMetric] = irisDetectionDynamicSensitivity(Icol_bin)
    % Initialiser les paramètres de sensibilité
    initialSensitivity = 0.859;  % Commencez avec une sensibilité plus basse
    maxSensitivity = 1.2;     % Sensibilité maximale à ne pas dépasser
    sensitivityStep = 0.02;    % Incrément de la sensibilité pour chaque itération

    % Détection pour le cercle iris/pupille
    [irisCenter, irisRadii, irisMetric] = tryFindCircles(Icol_bin, [100 160], 'bright', initialSensitivity, maxSensitivity, sensitivityStep);
end

function [centers, radii, metric] = tryFindCircles(Icol_bin, radiusRange, objectPolarity, initialSensitivity, maxSensitivity, sensitivityStep)  
    sensitivity = initialSensitivity;
    centers = [];
    radii = [];
    metric = [];
    
    % Tant que la sensibilité ne dépasse pas le maximum et qu'aucun cercle n'a été détecté
    while isempty(centers) && sensitivity <= maxSensitivity
        [centers, radii, metric] = imfindcircles(Icol_bin, radiusRange, 'ObjectPolarity', objectPolarity, 'Sensitivity', sensitivity);
        
        % Augmenter la sensibilité pour la prochaine itération si aucun cercle n'est trouvé
        if isempty(centers)
            sensitivity = sensitivity + sensitivityStep;
        end
    end
    
    % Afficher un message si aucun cercle n'est détecté même à la sensibilité maximale
    if isempty(centers)
        fprintf('Aucun cercle trouvé même avec une sensibilité de %.2f\n', maxSensitivity);
    else
        fprintf('Cercles trouvés avec une sensibilité de %.2f\n', sensitivity);
    end
end

figure,imagesc(Icol_bin),colormap(gray),title("found circles");

function [filteredCenters, filteredRadii, filteredMetric] = filterCircleCenters(centers, radii, metric, centreImageX, centreImageY, tolerance)
    % Initialisation des listes pour conserver les cercles filtrés
    filteredCenters = [];
    filteredRadii = [];
    filteredMetric = [];
    
    % Vérification initiale pour s'assurer que les centres ne sont pas vides
    if isempty(centers)
        return;
    end
    
    % Boucle à travers tous les cercles détectés pour filtrer basé sur une condition spécifique
    % Ici, comme exemple, on utilise la proximité au centre de l'image
    for i = 1:size(centers, 1)
        if abs(centers(i,1) - centreImageX) <= tolerance && abs(centers(i,2) - centreImageY) <= tolerance
            % Ajoute les cercles correspondants aux listes filtrées
            filteredCenters = [filteredCenters; centers(i,:)];
            filteredRadii = [filteredRadii; radii(i)];
            filteredMetric = [filteredMetric; metric(i)];
        end
    end
    
    % Filtrage supplémentaire pour choisir le cercle le plus proche du centre de l'image si nécessaire
    if size(filteredCenters, 1) >= 2
        distances = sqrt((filteredCenters(:,1) - centreImageX).^2 + (filteredCenters(:,2) - centreImageY).^2);
        [~, closestIndex] = min(distances);
        filteredCenters = filteredCenters(closestIndex, :);
        filteredRadii = filteredRadii(closestIndex);
        filteredMetric = filteredMetric(closestIndex);
    elseif isempty(filteredCenters) && ~isempty(centers)
        % Si aucun centre n'a été filtré mais que des centres existent, choisir le plus proche du centre de l'image
        distances = sqrt((centers(:,1) - centreImageX).^2 + (centers(:,2) - centreImageY).^2);
        [~, closestIndex] = min(distances);
        filteredCenters = centers(closestIndex, :);
        filteredRadii = radii(closestIndex);
        filteredMetric = metric(closestIndex);
    end
end

hold on;
% Vérification et affichage des cercles pour pupilFilteredCenters
if ~isempty(pupilFilteredCenters)
    viscircles(pupilFilteredCenters, pupilFilteredRadii, 'EdgeColor', 'b');
end

% Vérification et affichage des cercles pour irisFilteredCenters
if ~isempty(irisFilteredCenters)
    viscircles(irisFilteredCenters, irisFilteredRadii, 'EdgeColor', 'r');
end
hold off;

% Diameter calculation of the iris
centre_oeil_x = round(irisFilteredCenters(1,1));
centre_oeil_y = round(irisFilteredCenters(1,2));

% Radius calculation
r_int = round(pupilFilteredRadii);  % Outer radius of the iris
r_ext = round(irisFilteredRadii);  % Inner radius of the iris
end