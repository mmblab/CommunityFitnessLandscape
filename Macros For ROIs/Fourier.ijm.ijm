// This macro is intended to gather the data from a line ROI 
// and output a curve representing the bacterial growth trends
// This curve is to be filtered, sampled, and soted in a compact manner

roiManager("Select", 0); // Eventually will be for loop for each line ROI
Roi.getContainedPoints(xpoints, ypoints);

pixels = newArray(xpoints.length);

// Gets and prints raw data
print("Raw Data");
print("XVal\tYVal\tPVal");
for (i = 0; i < xpoints.length; ++i) {
	pixels[i] = getPixel(xpoints[i], ypoints[i]);
	print("" + xpoints[i] + "\t" + ypoints[i] + "\t" + pixels[i]);
}

// Tranformed data based off of raw data

cosines = fourier(pixels);
// Prints the data for testing
print("Unsorted Cosines");
print("Mag\tPhase\tFreq");
len = cosines.length/3;
for (i = 0; i < len; ++i) {
	print(cosines[i] + "\t" + cosines[len + i] + "\t" + cosines[2*len + i]);
}

print("Sorted Cosines");
cosines = sortCosines(cosines);
// Prints the data for testing
print("Mag\tPhase\tFreq");
len = cosines.length/3;
for (i = 0; i < len; ++i) {
	print(cosines[i] + "\t" + cosines[len + i] + "\t" + cosines[2*len + i]);
}

// Smooths data
smoothed = smoothN(pixels, 10);
print("Smoothed Data");
print("XVal\tYVal\tPVal");
for (i = 0; i < xpoints.length; ++i) {
	print("" + xpoints[i] + "\t" + ypoints[i] + "\t" + smoothed[i]);
}

cosines = fourier(smoothed);

print("Sorted Cosines");
cosines = sortCosines(cosines);
// Prints the data for testing
print("Mag\tPhase\tFreq");
len = cosines.length/3;
for (i = 0; i < len; ++i) {
	print(cosines[i] + "\t" + cosines[len + i] + "\t" + cosines[2*len + i]);
}

////////////////////////////////////////////////////////////////////////////
// Functions:

// This function sorts an array of cosines from largest magnitude
// to the smallest. 
//
// Format of Returned Data:
// 	Indexes				Data Contained
//	0 to len/3			- Magnitudes
//	len/3 to 2*len/3	- Phases
//	2*len/3 to len		- frequencies
function sortCosines(cosines) {
	// Gets the magnitudes of the cosines
	mags = Array.slice(cosines, 0, cosines.length/3);

	// Gets order of the magnitudes from smallest to largest
	order = Array.rankPositions(mags);

	// Reorders cosines into "sorted"
	sorted = newArray(cosines.length);
	len = cosines.length/3;
	for (i = 0; i < order.length; ++i) {
		// Calculates the position in the new array
		index = order.length - 1 - order[i];

		// Copies magnitude
		sorted[index] = cosines[i];
		// Copies phase
		sorted[index + len] = cosines[i + len];
		// Copies frequency
		sorted[index + 2*len] = cosines[i + 2*len];
	}

	return sorted;
}

// This function smooths the data held within an array, averaging
// over N data points
//
// Returned Data:
// 	The data returned by this function is of the same length as the
//	original array passed to it
function smoothN(pixelData, N) {
	// Smoothed data
	smoothed = newArray(pixelData.length);
	
	// Smooths the data for less than N indices
	for (i = 0; (i < N - 1) && (i < pixelData.length); ++i) {
		// Sums data in region under curve
		for (j = 0; j <= i; ++j) {
			smoothed[i] += pixelData[j];
		}

		// Averages the data point by i data points
		smoothed[i] = smoothed[i] / (i + 1);
	}

	// Smooths the data for N to pixelData.length indices
	for (i = N; i < pixelData.length; ++i) {
		// Sums region under the curve
		for (j = i - N + 1; j <= i; ++j) {
			smoothed[i] += pixelData[j];
		}

		// Avaerages by N data points
		smoothed[i] = smoothed[i]/N;
	}
	return smoothed;
}

// This function assumes the data exists purely in the real domain
// Calculates the cosine magnitudes, phases, and digital frequency
// 	Returns the values in a linearly indexed array holding the
// 	data for cosines from f = 0 to N/2
//
// Format of Returned Data:
// 	Indexes				Data Contained
//	0 to len/3			- Magnitudes
//	len/3 to 2*len/3	- Phases
//	2*len/3 to len		- frequencies
function fourier(pixelData) {
	// Truncates the last data point if N is not odd
	N = pixelData.length;
	if (pixelData.length%2 == 0) {
		N = pixelData.length + 1;
	}

	// Allocates space for cosines ranging in frequency
	//	from f = 0 to N/2, inclusive
	kLen = (N-1)/2 + 1;
	coefs = newArray(kLen*3);
	
	// Fourier Transform assuming purely real results
	for (k = 0; k < kLen; ++k) {
		// Digital frequency being measured
		omega = -2*PI*k/N;
		
		// Holds the summation values durring the process
		real = 0;
		imag = 0;
		
		// Summs the fourier transform for f = k/N
		for (n = 0; n < N; ++n) {
			real = real + cos(omega*n)*pixelData[n];
			imag = imag + sin(omega*n)*pixelData[n];
		}

		// Calculates the magnitude
		if (k == 0) {
			coefs[k] = sqrt(real*real + imag*imag)/N;
		} else {
			coefs[k] = 2*sqrt(real*real + imag*imag)/N;
		}

		// Calculates the phase
		coefs[kLen + k] = atan2(imag, real);

		// Calculates digital frequency (0 to 1/2)
		coefs[2*kLen + k] = k/N;
	}

	// Returns the coefficients, phases, and frequencies of the FT
	return coefs;
}