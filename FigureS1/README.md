# Code Usage For Diffusion Quantification Figure

FIJI (FIJI It's Just ImageJ) was used to measure diffusion data via microscopy. 

The scripts "Diffusion_Quantification_Circles.ijm" and "Diffusion_Quantification_Gradient.ijm" were used to extract diffusion data from a 24 hour diffusion time lapse sampled at 30 minute intervals.

The files "DiffusionCirclesROIAll.zip" and "DiffusionGradientROIAll.zip" were used to define the regions of interest for measurement.

## Gradient Diffusion
The file "GradientDiffusionData.txt" contains the measured raw data of the gradient of diffused materials. The gradient was sampled every 50 pixels
 - Every row is labeled in the format "t##c1" meaning time point ## chip 1
 - There are 25 time points, from t = 0 hours to t = 12 hours at 0.5 hour intervals

## Circle Diffusion
The file "Circle_diffusion.csv" contains the raw data for measuring the depleation of flourescent molecules from the variable wells of the device.
The indices of the variable wells are indicated in the image "Circle_ROI.jpg"
