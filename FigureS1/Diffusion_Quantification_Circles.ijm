// This macro opens a series of timelapse data for a diffusion experiment

// Opens the ROI Manager and loads the desired ROIs ONCE
// If opened each cycle, will measure same data over and over in the same timepoint
run("ROI Manager...");
roiManager("Open", "Z:/Duane/Nikon Scope Images/20200302 Diffusion/Device_all.zip");

// Directories
path = "Z:/Duane/Nikon Scope Images/20200302 Diffusion/";
imageFolder = "2020302 Triculture size diffusion/";

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
	roiManager("Measure");

	selectImage(nImages);
	close();
}
	saveAs("Results", path + "Circle_diffusion" + ".csv");