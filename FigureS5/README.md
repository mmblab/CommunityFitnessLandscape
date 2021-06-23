# Figure S5

## Layout Files
The files "layout1of2_10SpecsA.txt" and "layout1of2_10SpecsA.txt" define the experimental layout of the device with 10 different species of bacteria.
These layouts were used for the time lapse experiments and general experiments.

## Image J/FIJI Macros
The macros "Macro_xy1.ijm" and "Macro_xy2.ijm" were used to automate data collection from the time series microscopy images.
These macros stored the collected data for each device at each time point in an individual CSV file in the "CSV" folder.
Lossy compressed versions of the raw data can be seen in the "JPEG" folder

## Data Aggregation and Grouping
The MATLAB script, "BigDataSeries.m", was used to aggregate the data stored in the individual CSV files in the "CSV" folder.
This aggregated data was compiled into "20200206_TriMean_TimeSeries.csv" and sorted by species using the layout files mentioned above
