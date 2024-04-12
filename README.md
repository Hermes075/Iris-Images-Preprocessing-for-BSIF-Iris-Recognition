# Preprocessing of Iris Images for BSIF-Based Biometric Systems: Canny Algorithm and Iris Unwrapping

*Arthur Rubio, Lucas Rivière, "Preprocessing of Iris Images for BSIF-Based Biometric Systems: Canny Algorithm and Iris Unwrapping", IPOL (Image Processing On Line) 2023, Paris, France*

## Project Description
This project is divided into two main modules. The first module focuses on processing standard iris images, employing techniques like edge detection, normalization, and iris unwrapping using dynamic circle detection with the Hough Transform. Key scripts in this module include `extractRayon.m`, `extractIris.m` and `squareCircle.m`, which are called by `databaseUnwrapping.m`, which role is to . The second module is dedicated to iris recognition using a BSIF model, with scripts like `extractCode.m`, and `matchCodes.m` providing a similarity score between two iris images. Those scripts are used by `statistics.m` to calculate the comparison score and show the score distribution. If the score is high (over 0.385), the two irises does not belong to the same person. On the other hand, if the score is under 0.385, the irises belong to the same individual.

## Installation
To set up the project, install the MATLAB Image Processing Toolbox using the command `pkg load image`. No additional installations are required.

## Usage
### Preprocessing Iris Images
Run `databaseUnwrapping.m` to check the unwrapping demo on 5 images of the GFI dataset. The demo dataset is located in the DB_test/DB_tiff folder. You can see the unwrapping in the DB_test/DB_bmp folder, and the mask creation in DB_test/Masks_bmp.

### Iris Recognition
To compare iris images and check if they belong to the same individual, execute `statistics.m`. This code will show each comparison scores for genuine (same) and impostor (different) iris pairs, based on the `.csv` file mentionning the pairs of iris belonging (or not) to the same person. You can then see the start of the score distribution.
The code is based on the work of 4 professors in the University of Notre-Dame. See below for more details.

## Contributions
Contributions are welcome! Feel free to fork the repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

## Contact
For questions or feedback, please contact me at [arthurrubio0@gmail.com](mailto:arthurrubio0@gmail.com).

# Domain-Specific Human-Inspired Binarized Statistical Image Features for Iris Recognition

Iris image patches used in training and source codes of the method proposed in:

*Adam Czajka, Daniel Moreira, Kevin W. Bowyer, Patrick J. Flynn, "Domain-Specific Human-Inspired Binarized Statistical Image Features for Iris Recognition," WACV 2019, Hawaii, 2019*

Pre-print available at: https://arxiv.org/abs/1807.05248

Please follow the instructions at https://cvrl.nd.edu/projects/data/ to get copies of these sets.

WACV_2019_Czajka_etal_Stest_GENUINE.csv and WACV_2019_Czajka_etal_Stest_IMPOSTOR.csv files define genuine and impostor matching pairs used to generate Fig. 12 in the paper.

## License
This project is licensed under the GNU General Public License v3.0.