%% This script aggrigates the data from large data dseries into an easily usable matrix
%   Only contains 

filepath = 'G:\My Drive\Beebe Lab\Triculture\Data\BC_TimeLapse\CSV\';
layout1 = load('G:\My Drive\Beebe Lab\Triculture\Data\BC_TimeLapse\layout1of2_10SpecsA.txt');
layout2 = load('G:\My Drive\Beebe Lab\Triculture\Data\BC_TimeLapse\layout2of2_10SpecsA.txt');
means = zeros(176, 26);

% Iterates through each time point's data
for i = 1:25
    % Selects the desired files
    file1 = strcat(filepath, 't', num2str(floor(i/10)),num2str(rem(i,10)),'xy1c1.csv');
    file2 = strcat(filepath, 't', num2str(floor(i/10)),num2str(rem(i,10)),'xy2c1.csv');
    
    % Compiles the data for a given timepoint together
    dataByTri = agrigateData(file1,layout1);
    dataByTri2 = agrigateData(file2, layout2);
    dataByTri2.Index = dataByTri2.Index + max(dataByTri.Index, [], 'all');
    dataByTri = [dataByTri; dataByTri2];
    
    % Adds the data to the file
    means(:,1) = dataByTri.Combo;
    means(:, i + 1) = dataByTri.TriMean;
end


nums = [1,2,3,4,5,6,7,9,10,11];
numbers = cell(1,10);
for i = 1:10
    numbers{i} = getiwithn(means(:,1), nums(i));
end

figure
sgtitle('Time Lapse Data');
for i = 1:10
    subplot(3,4,i)
    plot(0:2:48, means(numbers{i},2:26)');
    title(strcat('Species #', num2str(nums(i))));
    ylim([0,15000]);
    ylabel('Fouresence');
    xlabel('Time (Hour)');
    xlim([0,48]);
    xticks(0:12:48);
end
%% Functions

% Groups data together
function [dataByTri] = agrigateData(filepath, layout)
    %AGRIGATEDATA puts index, triangle corners, mean reading, and
    %   standard deviation in one table
    
    dataTable = readtable(filepath);

    % Gets the maximum well value represented
    maxVar = max(layout, [], 'all');

    % Calculates the number of triangles, then get the arrayID list
    numTris = calcNumTris(layout);
    unsortedArrayID = getCombos(layout);
    arrayID = sortCombos(unsortedArrayID);
    
    % Gets Index ID and loads each species ID from lowest to
    % highest
    for i = 1:numTris
        % Creates arrays to be used to make table
        Index(i) = i; % Index of Triangle
        Combination(i) = arrayID(i,1);
        SpeciesNum1(i) = floor(unsortedArrayID(i,1)/10000);
        SpeciesNum2(i) = floor(rem(unsortedArrayID(i,1),10000)/100);
        SpeciesNum3(i) = rem(unsortedArrayID(i,1),100);
    end


    dataByTri = table(Index', Combination', SpeciesNum1', SpeciesNum2', SpeciesNum3', dataTable.Mean(1:numTris),dataTable.StdDev(1:numTris));
    dataByTri.Properties.VariableNames = {'Index' 'Combo' 'Species_1' 'Species_2' 'Species_3' 'TriMean' 'TriStDev'};

    mean = dataTable.Mean(numTris+1:4*numTris);
    stdev = dataTable.StdDev(numTris+1:4*numTris);
    
    for i = 1:numTris
        coord = (i-1)*3+1;
        spec1mean(i) = mean(coord);
        spec1stdv(i) = stdev(coord);
        spec2mean(i) = mean(coord+1);
        spec2stdv(i) = stdev(coord+1);
        spec3mean(i) = mean(coord+2);
        spec3stdv(i) = stdev(coord+2);
    end

    cornerData = table(spec1mean',spec1stdv',spec2mean',spec2stdv',spec3mean',spec3stdv');
    cornerData.Properties.VariableNames = {'Species_1_Mean' 'Species_1_STDEV' 'Species_2_Mean' 'Species_2_STDEV' 'Species_3_Mean' 'Species_3_STDEV'};
    dataByTri = [dataByTri, cornerData];
end

% Gets Combinations
function arrayID = getCombos(layout)
    numTris = calcNumTris(layout);
    %GETCOMBOS Returns list of combination IDs
    layout = layout';
    [i,j] = size(layout);
    tempArray = zeros(numTris,3);
    tempCount = 1;
    arrayID = zeros(numTris,1);

    for row = 1:i-1
        for col = 1:j-1
            yOdd = rem(row,2);
            if (yOdd)
                tempArray(tempCount,1) = layout(row,col);
                tempArray(tempCount,2) = layout(row+1,col);
                tempArray(tempCount,3) = layout(row+1,col+1);
                tempCount = tempCount+1;

                tempArray(tempCount,1) = layout(row,col);
                tempArray(tempCount,2) = layout(row,col+1);
                tempArray(tempCount,3) = layout(row+1,col+1);
                tempCount = tempCount+1;
            else
                tempArray(tempCount,1) = layout(row,col);
                tempArray(tempCount,2) = layout(row,col+1);
                tempArray(tempCount,3) = layout(row+1,col);
                tempCount = tempCount+1;

                tempArray(tempCount,1) = layout(row,col+1);
                tempArray(tempCount,2) = layout(row+1,col);
                tempArray(tempCount,3) = layout(row+1,col+1);
                tempCount = tempCount+1;
            end
        end
    end

    for i = 1:numTris
        arrayID(i,1) = 10000*tempArray(i,1);
        arrayID(i,1) = arrayID(i,1)+100*tempArray(i,2);
        arrayID(i,1) = arrayID(i,1)+tempArray(i,3);
    end
end

% Calculates the number of triangles in a layout
function numTris = calcNumTris(layout)
    [width, height] = size(layout);
    numTris = (width-1)*(height-1)*2;
end

% Sorts the combinations
function newArrayID = sortCombos(arrayID)

    for i = 1:length(arrayID)
        smallArray = getIndiv(arrayID(i,1));

        for j = 1:length(smallArray)
            for k = 1:length(smallArray)-1
                if smallArray(k,1) > smallArray(k+1,1)
                    temp = smallArray(k,1);
                    smallArray(k,1) = smallArray(k+1,1);
                    smallArray(k+1,1) = temp;
                end
            end
        end

        newArrayID(i,1) = 10000*smallArray(1,1);
        newArrayID(i,1) = newArrayID(i,1)+100*smallArray(2,1);
        newArrayID(i,1) = newArrayID(i,1)+smallArray(3,1);
    end
end

% Helper for sortCombos
function indivSpec = getIndiv(combo)
    indivSpec = zeros(3,1);
    indivSpec(1,1) = (combo-rem(combo,10000))/10000;
    indivSpec(2,1) = (rem(combo,10000)-rem(combo,100))/100;
    indivSpec(3,1) = rem(combo,100);
end

% Gets the indexes of time series which contain a given number
function indexes = getiwithn(labels, n)
    num1 = floor(labels./10000);
    num2 = floor(mod(labels,10000)./100);
    num3 = mod(labels, 100);
    
    indexCount = 1;
    for i = 1:length(labels)
        if ((num1(i) == n) || (num2(i) == n) || (num3(i) == n))
            indexes(indexCount) = i;
            indexCount = indexCount + 1;
        end
    end
    
    if indexCount == 1
        indexes = 0;
    end
end