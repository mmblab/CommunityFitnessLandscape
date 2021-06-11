run("ROI Manager...");
roiManager("Open", "Y:/Duane/Nikon Scope Images/ROIs/New ROI/88-well_Triculture_triangle_plus_edge.zip");
for (i = 1; i <= 25; ++i) {
fileName = "t" + floor(i/10) + "" + i%10 + "xy1c1.tif";
path = "Y:/Duane/Nikon Scope Images/20200221 THOR Bacillus timelapse/20191018 THOR Triculture timelapse/";
open(path + fileName);
fileName = substring(fileName, 0, lastIndexOf(fileName, "."));
run("Rotate... ", "angle=0.36 grid=5 interpolation=Bilinear");
run("ROI Manager...");
roiManager("Show All with labels");
roiManager("Measure");
saveAs("Results", path + "CSV/" + fileName + ".csv");
run("Close");
run("Green");
run("RGB Color");
run("Set Scale...", "distance=0.3085 known=1 pixel=1 unit=micron");
run("Scale Bar...", "width=5000 height=100 font=224 color=White background=None location=[Lower Right] bold hide");
saveAs("Jpeg", path + "JPEG/" + fileName + ".jpg");
run("Close All");
}
