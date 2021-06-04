macro "GetAndPrintLine" {
// This macro simply gets all of the values within a line ROI
roiManager("Select", 0);
Roi.getContainedPoints(xpoints, ypoints);
print("XVal\tYVal\tPVal");

for(i = 0; i < xpoints.length; ++i) {
	print("" + xpoints[i] + "\t" + ypoints[i] + "\t" + getPixel(xpoints[i], ypoints[i]));
	}
}
