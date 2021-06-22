// This macro opens a series of timelapse data for a diffusion experiment

// Opens the ROI Manager and loads the desired ROIs ONCE
// If opened each cycle, will measure same data over and over in the same timepoint
run("ROI Manager...");
roiManager("Open", "Z:/Duane/Nikon Scope Images/20200302 Diffusion/DiffusionROIs.zip");

// Directories
path = "Z:/Duane/Nikon Scope Images/20200302 Diffusion/";
imageFolder = "2020302 Triculture size diffusion/";
sf = 50; // scale factor for resampling

// Prints the file header
print("2020302 Triculture Size Diffusion Experiemnt");
print("Image\tROI\tData");

// Iterates through each image in the data set
for (i = 1; i <= 25; ++i) {
	// Opens the images
	fileName = "t" + floor(i/10) + "" + i%10 + "c1.tif";
	open(path + imageFolder + fileName);
	fileName = substring(fileName, 0, lastIndexOf(fileName, "."));

	// Activates the ROIs
	run("ROI Manager...");
	roiManager("Show All with labels");

	// Iterates through the ROIs
	nROIs = roiManager("count");
	for (j = 0; j < nROIs; ++j) {
		roiManager("Select",j);
		// Samples the pixel coordinates for fewer data points
		Roi.getContainedPoints(xpoints, ypoints);
		xpoints = Array.resample(xpoints, floor(xpoints.length/sf));
		ypoints = Array.resample(ypoints, floor(ypoints.length/sf));

		// Gets the sampled pixel data
		pixels = "";
		for (k = 0; k < xpoints.length; ++k) {
			pixels = pixels + "\t" + getPixel(xpoints[k], ypoints[k]);
		}

		// Prints the output
		print(fileName + "\t" + (j+1) + pixels);
	}
	
	selectImage(nImages);
	close();
}