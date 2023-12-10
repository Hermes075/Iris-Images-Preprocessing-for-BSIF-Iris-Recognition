function noisy_img = f_addSaltPepperNoise(original_img, density)
    % original_img : Image originale
    % density : Densité du bruit (entre 0 et 1)
    % noisy_img : Image avec bruit "sel et poivre"

    noisy_img = imnoise(original_img, 'salt & pepper', density);
end

