# Preprocessing of Iris Images for BSIF-Based Biometric Systems: Canny Algorithm and Iris Unwrapping

*Arthur Rubio, Lucas Rivière, "Preprocessing of Iris Images for BSIF-Based Biometric Systems: Canny Algorithm and Iris Unwrapping" IPOL (Image Processing On Line) 2023, Paris, France*

## Project Description
This project is divided into two main modules. The first module focuses on processing standard iris images, employing techniques like edge detection, normalization, and iris unwrapping. Key scripts in this module include `extractRayon.m`, `extractIris.m` and `squareCircle.m`. The second module is dedicated to iris recognition using a BSIF model, with scripts like `example.m`, `extractCode.m`, and `matchCodes.m` providing a similarity score between two iris images. If the score is high (over 0.3), the two irises does not belong to the same person. On the other hand, if the score is under 0.3, the irises belong to the same individual.

## Installation
To set up the project, install the MATLAB Image Processing Toolbox using the command `pkg load image`. No additional installations are required.

## Usage
### Preprocessing Iris Images
Run `squareCircle.m` after specifying the target image in `extractIris.m`. This process includes steps like radius extraction and iris normalization.

### Iris Recognition
To compare iris images, execute `example.m`. Edit lines 34 to 40 to specify the images you wish to compare. This module will generate a similarity score, indicating whether the irises belong to the same person or different individuals.

## Areas for Improvement
1. Enhancing the `f_centre` function for more accurate iris centering.
2. Implementing adaptive thresholding based on image lighting conditions for more effective segmentation and custom mask creation.

## Contributions
Contributions are welcome, especially in the areas of improvement mentioned above! Feel free to fork the repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the GNU General Public License v3.0.

## Contact
For questions or feedback, please contact me at [arthurrubio0@gmail.com](mailto:arthurrubio0@gmail.com).



# Domain-Specific Human-Inspired Binarized Statistical Image Features for Iris Recognition

Iris image patches used in training and source codes of the method proposed in:

*Adam Czajka, Daniel Moreira, Kevin W. Bowyer, Patrick J. Flynn, "Domain-Specific Human-Inspired Binarized Statistical Image Features for Iris Recognition," WACV 2019, Hawaii, 2019*

Pre-print available at: https://arxiv.org/abs/1807.05248

Please follow the instructions at https://cvrl.nd.edu/projects/data/ to get copies of these sets.

WACV_2019_Czajka_etal_Stest_GENUINE.csv and WACV_2019_Czajka_etal_Stest_IMPOSTOR.csv files define genuine and impostor matching pairs used to generate Fig. 12 in the paper.