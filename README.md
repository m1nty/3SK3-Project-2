# COMPENG 3SK3: Computer-Aided Engineering Project 2 #

### Minhaj Shah / 400119266
### April 10, 2021


## Setup Instructions for MATLAB

1.	This project was completed in MATLAB. Please download MATLAB if you do not have it already. Details can be found at the following link: https://www.mathworks.com/downloads/

2.	Image Processing Toolbox is a very common MATLAB add on. Please install this since it is used throughout the program. Details can be found using the following link: https://www.mathworks.com/products/image.html

3.	Either use GitHub to clone the repository on your machine or download the zip folder that was included in the submission folder in Avenue called Project 2. To learn how to quickly clone the project from GitHub, follow the instructions here: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository 


## Repository Structure Breakdown

This section is a breakdown of the Repository for a new user of the program to understand and navigate through it. The next section will discuss how to run the actual program. The Project 2  `src` Folder will have the structure as shown in the picture below.

![image](https://user-images.githubusercontent.com/64797254/114290601-cc42f980-9a4e-11eb-819d-8704eb8f4939.png)

Below is a quick breakdown of what is inside the `src` folder.
  - `linearRegression`
    - This is the main file of the MATLAB program. The coefficent matrices generation, linear regresion and MSE calculations are all done here. 
  
  - `input_coeff_img.jpeg`
    - This is the input image for the Coefficent Matrices Generation.

  - `input_demosaic_img.jpeg`
    - This is the input image for the linear regression demosaicing program.

  - `singleChannel.png`
    - This is the black and white single channel image. 

  - `linearRegressionDemosaic.png`
    - This is the resulting image from the linear regression demosaic program. 

  - `matlabDemosaic.png`
    - This is the resulting image from MATLAB's demosaic function. 


## How to Run the Program

All the user needs to do is specify the input images, and run `linearRegression.m`. Simple instructions on how to do this are given below:

1.	By default, the program assumes that the input images are called `input_demosaic_img.jpeg` and `input_coeff_img.jpeg`. The input images can be provided in two easy ways:

      1. Re-name the images you want to input to the names specified above. 

      2. Or, open `linearRegression.m` and edit `line 11` and `line 46`. Then simply just change the name to whatever the image is called in the string.
 
2.	To run the program now, run `linearRegression.m` in MATLAB.

    While the program is executing, things will be printed to console to indicate the status of what is happening. You should see the following text in the console:
    
    ![image](https://user-images.githubusercontent.com/64797254/114290376-3f4b7080-9a4d-11eb-8338-32ca48347494.png)

3.	The resulting demosaiced images will be written and located in the `src` folder. Refer back to the Repository Break Down Section if more detail is needed on how the Program works. 

4.	The Mean Squared Error will be printed in the console as shown in the screenshot above. 

5.	Repeat from Step 1 with a new Input Image. Enjoy!
