classdef TriCultureFunc
    %THORFUNC
    %This is a methods class which holds all functions used in the
    %   TriCulture Layout processor.

    methods(Static)
        function int = calcCombos(inVars)
        %COUNTCOMBOS Calculates all possible combinations of any group of three
        %variables.
            int = 0;
            for i = 1 : 1 : (inVars - 2)
                for j = i + 1: 1 : (inVars - 1)
                    for k = j +1 : 1 : inVars
                        if (k <= inVars) 
                            int = int + 1;
                        end
                    end
                end
            end
        end

        function anotated = printLayout(printLay)
            %PRINTLAYOUT Prints out a an image of the layout with color coded and
            %   numbered wells.
            %The function returns a MATLAB image file which can
            %   be saved for later use.

            % Offsets ued to inciment throught image
            xStart  = 85;
            xChange = 91.5;
            yStart  = 37;
            yChange = 77.2;
            clrAr   = {'blue','green','red','cyan','magenta','yellow','white'};

            [x,y] = size(printLay);
            figure
            layout = imread('blankLayout.png');
            anotated = layout;

            % Adds circles
            for i = 1:x
                for j = 1:y
                    if rem(j,2)
                        xCoord = xStart + xChange*(i-1);
                        yCoord = yStart + yChange*(j-1);
                        clr    = clrAr(rem(printLay(i,j),7)+1);
                        anotated=insertShape(anotated,'FilledCircle',[xCoord yCoord 20],'Color',clr);
                    else
                        xCoord = xStart - xChange/2 + xChange*(i-1);
                        yCoord = yStart + yChange*(j-1);
                        clr    = clrAr(rem(printLay(i,j),7)+1);
                        anotated=insertShape(anotated,'FilledCircle',[xCoord yCoord 20],'Color',clr);
                    end
                end
            end
            % Adds text
            for i = 1:x
                for j = 1:y
                    if rem(j,2)
                        xCoord = xStart + xChange*(i-1);
                        yCoord = yStart + yChange*(j-1);
                        outstring = num2str(printLay(i,j));
                        anotated = insertText(anotated,[xCoord,yCoord],outstring,'AnchorPoint','Center','BoxOpacity',0);
                    else
                        xCoord = xStart - xChange/2 + xChange*(i-1);
                        yCoord = yStart + yChange*(j-1);
                        outstring = num2str(printLay(i,j));
                        anotated = insertText(anotated,[xCoord,yCoord],outstring,'AnchorPoint','Center','BoxOpacity',0);
                    end
                end
            end
            imshow(anotated);
        end

        function layout = fillRandom(var,x,y)
        % Fills a device with random arrangment of wells 1-var, with no neighboring
        %   wells having the same variable.
            layout = zeros(x,y);
            for i = 1 : 1 : x
                for j = 1 : 1 : y
                    found = 1;
                    while (found == 1)
                        wellVar = randi(var);
                        surround = checkArround(layout, i, j, x, y);
                        found = findMatch(surround, wellVar);
                        if (found == 0)
                            layout(i,j) = wellVar;
                        end
                    end
                end
            end
        end

        function [variance, portOfComb, minOf3] = comboStats(layout, numCombos)
            arrayID = getCombos(layout);
            arrayID = sortCombos(arrayID);
            arrayID = sortrows(arrayID, 1);

            comp = arrayID(1,1);
            storage = zeros(numCombos, 1);
            comboCounter = 1;
            comboIndex = 1;
            
            numTris = calcNumTris(layout);

            for i = 1:numTris-1
                if ((comp == arrayID(i+1,1)) && (i<numTris))
                    comboCounter = comboCounter + 1;
                else
                    comp = arrayID(i+1,1);
                    storage(comboIndex,1) = comboCounter;
                    comboIndex = comboIndex + 1;
                    comboCounter = 1;
                    if ((i+1)==numTris)
                        storage(comboIndex,1) = comboCounter;
                    end
                end
            end

            % Calculates the variance of the nonZero values in the set
            count = 1;
            for i = 1:length(storage)
                if storage(i,1) ~= 0
                    nonZero(count) = storage(i,1);
                    count = count + 1;
                end
            end
            variance = var(nonZero);

            % Calculates the proportion of the possible combinations that are
            % represented
            comboCounter = 1;
            for i = 1:numCombos
                if (storage(i,1)>0)
                    comboCounter = comboCounter + 1;
                end
            end
            portOfComb = comboCounter/numCombos;

            % If the minimum number of replicates is less than three, that means
            % not all trials will have statistical significance
            for i = 1:length(storage)  
                if (storage(1,1) < 3)
                    minOf3 = 0;
                else
                    minOf3 = 1;
                end
            end
        end

        function index = findBest(stats)
            %FINDBEST Finds the best layout, first by searching for an
            %   array with at least threee replicates
            
            arrayMax = length(stats);
            indexArray = zeros(arrayMax, 4);
            index = 0;
            indIndex = 1;
            varIndex = 2;
            pOCIndex = 3;
            mO3Index = 4;
            
            % Gives an index tag for the various stats so the data is saved
            %   as index, variance, portOfComb, and a boolean for if a min
            %   of 3 was detected for each index
            for i = 1:arrayMax
                indexArray(i,1) = i;
                for j = 1:3
                    indexArray(i,j+1) = stats(i,j);
                end
            end
            %% First Rule
            %   Scans for any combo with 3 replicates and 100% of possible
            %       combos represented.
            parsedArray = zeros(1,4);
            counter = 0;
            for i = 1:arrayMax
                % If 100% of combos represetned and (min of 3 reps per
                %   combo)=true
                if ((indexArray(i,pOCIndex)==1) && (indexArray(i,mO3Index)==1))
                    %Copies rows that meat this standard into parsedArray
                    for j = i:4
                        parsedArray(counter+1,j)=indexArray(i,j);
                        counter = counter + 1;
                    end
                end
            end
            
            % Checks if any array was found, and sorts to find array with
            %   least variance, indicating the most equal distribution
            if counter > 0
                parsedArray = sortrows(parsedArray, varIndex);
                index = parsedArray(1,indIndex);
            end
            
            %% Second Rule
            %   First, sorts by the portion of the possible combinations
            %       space represented, then by lowest variance so that the
            %       final board will bave the highest percent of available
            %       combinations with the lowestest amount of variance in
            %       the number of relicates.
            if index == 0
                indexArray = sortrows(indexArray, [pOCIndex varIndex]);
                index = indexArray(1,1);
            end
            
            %% Third Rule
            %   If the index is not returned, it returns null
            if index == 0
                index = NaN;
            end
        end
        
        function posCombo = getPosCombos(numVars)
            %GETPOSCOMBOS gets all the possible combinations of for a given
            %   number of variable wells stoed smallest to largest in each
            %   row with one extra collumn for the replicates count
            posCombo = zeros(TriCultureFunc.calcCombos(numVars), 4);
            row = 1;
            for i = 1:numVars-2
                for j = i+1:numVars-1
                    for k = j+1:numVars
                        posCombo(row,:) = [i, j, k, 0];
                        row = row+1;
                    end
                end
            end
        end

        function [layout, comboList] = fillLayoutRandom(layout, comboList, maxReps)
            %FILLLAYOUT randomly fills the layout while trying to fill as
            %   much of the combination space as possible.
            
            [maxRows, maxCols] = size(layout);
            noOptions = false;
            comboList2 = comboList;
            
            for col = 1:maxCols
                for row = 1:maxRows
                    neighbors = checkArround(layout, row, col, maxRows, maxCols);
                    options = findBestChoice(comboList2, neighbors(1:3), maxReps);
                    if options(1) > 0
                        layout(row,col) = options(randi([1,length(options)]));
                        comboList2 = markReps(comboList2, neighbors, layout(row,col));
                    else
                        noOptions = true;
                        break;
                    end
                end
                if noOptions
                    break;
                end
            end
            
            if noOptions
                layout = zeros;
            else
                comboList = comboList2;
            end
        end
        
        function filepath = exportLayout(image, matrix, filepath)
            disp('Input filemane :');
            pause(2);
            [filename, filepath] = uiputfile('*.*','',filepath);
            filename = strcat(filepath,filename);
            
            % Exports the generated layout in a text format
            dlmwrite(strcat(filename, '.txt'),matrix,'delimiter','\t','newline','pc');

            % Exports the generated layout in a graphical format
            imwrite(image, strcat(filename, '.tif'), 'tif');
        end
        
        function filepath = exportTable(tbl2export,filepath)
            disp('Please input the filename for the table')
            pause(2);
            [filename, filepath] = uiputfile('*.csv','',filepath);
            
            writetable(tbl2export, strcat(filepath,filename));
        end
        
        function [layout,filepath] = importLayout(prompt,filepath)
            disp(prompt);
            pause(2);
        
            [filename,filepath] = uigetfile('*.*','',filepath); 
            layout = load(strcat(filepath,filename));
        end
        
        function [table, filepath] = importTable(prompt,filepath)
            %IMPORTABLE Takes a string prompt, and returns the table. The
            %   filepath is returned to make the next file save easier
            disp(prompt);
            pause(3);
        
            % Opens the UI file explorer at filepath the most recently used
            %   filepath
            [filename, filepath] = uigetfile('*.*','',filepath); 
            table = readtable(strcat(filepath,filename));
        end
        
        function [dataByTri, layout, filepath] = agrigateData(filepath)
            %AGRIGATEDATA puts index, triangle corners, mean reading, and
            %   standard deviation in one table
            [layout, filepath] = TriCultureFunc.importLayout('Please select the layout file',filepath);
            TriCultureFunc.printLayout(layout);
            
            
            [dataTable, filepath] = TriCultureFunc.importTable('Please select the unprocessed data file', filepath);
            
            % Gets the maximum well value represented
            maxVar = max(layout, [], 'all');

            % Calculates the number of triangles, then get the arrayID list
            numTris = calcNumTris(layout);
            unsortedArrayID = getCombos(layout);
            arrayID = sortCombos(unsortedArrayID);
            %% Gets 
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
            
            prompt = 'Corner ROIs(Y/N)?:\n';
            corners = input(prompt, 's');
            
            if (corners == 'Y' || corners == 'y') && height(dataTable)==4*numTris
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
                
            elseif (corners == 'Y' || corners == 'y') && height(dataTable)~=4*numTris
                'Data is not valid for corner ROIs.\nReutrned tables without corner ROI data'
            end
        end
        
        function [dataByBug dataByBugSimple] = organizeByBug(dataByTri)
            % ORGANIZEBYBUG takes a data table already organized by
            %   triangle, then sorts it by bug. Two tables are generated.
            %
            % The first is a .mat table. This table mainatains almost every
            %   piece of data in the dataByTri array by storing each and
            %   every mean and standard deviation for a bug and its given
            %   combination
            %
            % The second table is a .txt table in which just the mean and
            %   standard deviation of the means is stored
            
            % Comaparison value to determine if the table has corner ROIs
            numColsNoCorners = 7;
            
            % Total number of triangles
            numTris = height(dataByTri);
            
            % Gets the list of comboIDs without ID replicates and gets the
            %   maximum number of replicates at for any combo
            dataByTri = sortrows(dataByTri, 'Combo');
            [comboList maxReps] = getParsedCombos(dataByTri.Combo);
            
            % A string version of the combo ids to make collum titles 
            for i = 1:length(comboList)
                comboStringList(i) = {int2str(comboList(i))};
            end
            
            % Creates mean and stdev titles
            comboMeanTitles = strcat('MEAN_', comboStringList);
            comboSTDVTitles = strcat('STDV_', comboStringList);
            
            % Gets the maximum species ID and fills up to that point
            presentSpecies = [dataByTri.Species_1, dataByTri.Species_2, dataByTri.Species_3];
            numBugs = max(presentSpecies, [], 'all');
            
            % Determine if corner ROIs were used in the data
            if width(dataByTri)<=numColsNoCorners % Corner ROIs not used
                % Prepare collumns for the new table
                % The number corresponding to the bug
                bugIDs = 1:1:numBugs;
                
                dataByBug = table(bugIDs');
                dataByBug.Properties.VariableNames = {'BugID'};
                
                % Makes an array with the same number of rows as number of
                %   bugs, and the same number of collumns as entries in
                %   comboList. Each element in this array is a 1:maxReps
                %   array.
                means = zeros(1, maxReps, numBugs, length(comboList));
                stdev = zeros(1, maxReps, numBugs, length(comboList));
                
                % Iterates through all possible bugs in array
                for searchBug = 1:numBugs
                    repIndex = 1;
                    % Searches for all instances of searchBug
                    for rowInData = 1:height(dataByTri)
                        bugsInCombo = presentSpecies(rowInData,:);
                        for k = 1:3
                            % If the search bug is present in row
                            if bugsInCombo(1,k) == searchBug
                                % Finds the index of the collumn for the
                                %   location of the data
                                indexOfID = find(comboList == dataByTri.Combo(rowInData));
                                
                                % Copies data into arrays
                                means(1, repIndex, searchBug, indexOfID) = dataByTri.TriMean(rowInData);
                                stdev(1, repIndex, searchBug, indexOfID) = dataByTri.TriStDev(rowInData);
                            end
                        end
                    end
                end
                
                % Copies all mean data to tables
                for column = 1:length(comboList)
                    tempColMean = cell(1,numBugs);
                    
                    for row = 1:numBugs
                        tempColMean(row) = {means(:,:,row,column)};
                    end
                    
                    dataByBug = addvars(dataByBug, tempColMean', 'NewVariableNames', comboMeanTitles{column});
                end
                
                % Copies all stdev data to tables
                for column = 1:length(comboList)
                    tempColStDev = cell(1,numBugs);
                    
                    for row = 1:numBugs
                        tempColStDev(row) = {stdev(:,:,row,column)};
                    end
                    
                    dataByBug = addvars(dataByBug, tempColStDev', 'NewVariableNames', comboSTDVTitles{column});
                end
                
                % Creates a simple table to be easily opened in excel
                dataByBugSimple = table(bugIDs');
                dataByBugSimple.Properties.VariableNames = {'BugID'};
                % Copies all mean data to tables
                for column = 1:length(comboList)
                    tempColMean = zeros(numBugs,1);
                    
                    for row = 1:numBugs
                        tempColMean(row) = mean(nonzeros(cell2mat(dataByBug{row, column+1})));
                    end
                    
                    dataByBugSimple = addvars(dataByBugSimple, tempColMean, 'NewVariableNames', comboMeanTitles{column});
                end 
                % Copies all stdev data to tables
                for column = length(comboList)+1:2*length(comboList)
                    tempColStDev = zeros(numBugs,1);
                    
                    for row = 1:numBugs
                        tempColStDev(row) = mean(nonzeros(cell2mat(dataByBug{row, column+1})));
                    end
                    
                    dataByBugSimple = addvars(dataByBugSimple, tempColStDev, 'NewVariableNames', comboSTDVTitles{column-length(comboList)});
                end 
            else % Corner ROIs used
                
            end
            
            
        end
        
        function vignettes = vignetteGen(dataByTri, hasCorners)
            % VIGNETTEGEN Generates a 3D array storing the vingettes of
            %   each species.
            % The vignettes will be stored in a three dimensional array
            %   the first two dimentsions representing species 1 through
            %   numspecies and species 2 through num species. The third
            %   dimension will represent the species the vignette is for
            
            
            
            % Total number of triangles
            numTris = height(dataByTri);
            
            % Gets the list of comboIDs without ID replicates and gets the
            %   maximum number of replicates at for any combo
            dataByTri = sortrows(dataByTri, 'Combo');
            [comboList maxReps] = getParsedCombos(dataByTri.Combo);
            
            % Finds the highest number coordinating to a species
            presentSpecies = [dataByTri.Species_1, dataByTri.Species_2, dataByTri.Species_3];
            specMax = max(presentSpecies, [], 'all');
            
            % Prepares the vignette space
            vignettes = zeros(specMax, specMax, specMax);
            
            % Prepares various counting vars for iteration
            start = 2;
            sum = 0;
            count = 0;
                
            if ~hasCorners % Code for compiling whole trianlge means
                for vigNum = 1:specMax
                    comboPrev = dataByTri.Combo(start-1);
                    for triRow = start:numTris
                        combo = dataByTri.Combo(triRow);
                        if combo == comboPrev
                            % If the combination is the same as the previous,
                            count = count+1;
                            sum = sum + dataByTri.TriMean(triRow-1);
                        else
                            % Adds previous coordinate to the count
                            count = count+1;
                            sum = sum + dataByTri.TriMean(triRow-1);
                            
                            % Gets the mean for the vignette location and stores it
                            mean = sum/count;
                            coord = getIndiv(comboPrev);
                            if findMatch(coord', vigNum)
                                values = coord(coord ~= vigNum);
                                
                                yval = min(values);
                                xval = max(values);
                                
                                % Testing code
                                % [xval yval vigNum]
                                
                                vignettes(yval, xval, vigNum) = mean;
                            end
                            % Sets count and sum to zero
                            count = 0;
                            sum = 0;
                            comboPrev = combo;
                        end
                    end
                end
            else % Code for compiling corner ROIs
                for vigNum = 1:specMax
                    comboPrev = dataByTri.Combo(start-1);
                    for triRow = start:numTris
                        combo = dataByTri.Combo(triRow);
                        if combo == comboPrev
                            % If the combination is the same as the
                            % previous, adds the mean to the total
                            count = count+1;
                            search = presentSpecies(triRow-1,:);
                            
                            % Determines which corner mean to use
                            if search(1) == vigNum
                                sum = sum + dataByTri.Species_1_Mean(triRow-1);
                            elseif search(2) == vigNum
                                sum = sum + dataByTri.Species_2_Mean(triRow-1);
                            elseif search(3) == vigNum
                                sum = sum + dataByTri.Species_3_Mean(triRow-1);
                            end
                        else
                            % Adds previous coordinate to the count
                            count = count+1;
                            search = presentSpecies(triRow-1,:);
                            
                            % Determines which corner mean to use
                            if search(1) == vigNum
                                sum = sum + dataByTri.Species_1_Mean(triRow-1);
                            elseif search(2) == vigNum
                                sum = sum + dataByTri.Species_2_Mean(triRow-1);
                            elseif search(3) == vigNum
                                sum = sum + dataByTri.Species_3_Mean(triRow-1);
                            end
                            
                            % Gets the mean for the vignette location and stores it
                            mean = sum/count;
                            coord = getIndiv(comboPrev);
                            if findMatch(coord', vigNum)
                                values = coord(coord ~= vigNum);
                                
                                yval = min(values);
                                xval = max(values);
                                
                                % Testing code
                                % [xval yval vigNum]
                                
                                vignettes(yval, xval, vigNum) = mean;
                            end
                            % Sets count and sum to zero
                            count = 0;
                            sum = 0;
                            comboPrev = combo;
                        end
                    end
                end
            end
        end
        
        function figveiw = vignettePrintAll(vignetteArray)
            maxHeat = max(vignetteArray, [], 'all');
            minHeat = min(nonzeros(vignetteArray), [], 'all');
            
            numVigs = size(vignetteArray,3);
            height = floor(sqrt(numVigs));
            width = ceil(sqrt(numVigs));
            
            figveiw = figure;
            for curVig = 1:numVigs
                subplot(height, width, curVig);
                hold on
                grid on
                for i = 1:numVigs
                    plot([i, i], [0, i-1], ':k');
                end
                
                vignette = vignetteArray(:, :, curVig);
                [vheight, vwidth] = size(vignette);
                for ycoord = 1:vheight
                    for xcoord = 1:vwidth
                        value = vignette(ycoord, xcoord);
                        if value ~= 0
                            color1 = 0.95-0.6*(value-minHeat)/(maxHeat-minHeat);
                            color2 = 0.95-0.3*(value-minHeat)/(maxHeat-minHeat);
                            color3 = 0.95-0.5*(value-minHeat)/(maxHeat-minHeat);
                            clrAr = [color1 color2 color3];
                            yCenter = ycoord;
                            xCenter = xcoord;
                            
                            squarex = [xCenter-0.5, xCenter-0.5, xCenter+0.5, xCenter+0.5, xCenter-0.5];
                            squarey = [yCenter-0.5, yCenter+0.5, yCenter+0.5, yCenter-0.5, yCenter-0.5];
                            
                            sqr = fill(squarex, squarey, clrAr);
                            set(sqr,'EdgeColor', 'none');
                        end
                    end
                end
                xlim([1.3 vwidth+0.8]);
                xticks(1:1:numVigs);
                ylim([0.3 vheight-0.2]);
                yticks(1:1:numVigs);
                title(strcat('Bug: ', int2str(curVig)));
                hold off
            end
            sgtitle(input('Input a title.\n','s'));
        end
        
        function vignettePrintAllDelta(vigTri, vigCorn)
            [row, col, plane] = size(vigTri);
            vignetteArray = zeros(row,col,plane);
            for i = 1:row
                for j = 1:col
                    for k = 1:plane
                        vignetteArray(i,j,k) = vigCorn(i,j,k)/vigTri(i,j,k);
                    end
                end
            end
            maxHeat = max(vignetteArray, [], 'all');
            
            numVigs = size(vignetteArray,3);
            height = floor(sqrt(numVigs));
            width = ceil(sqrt(numVigs));
            
            figure
            for curVig = 1:numVigs
                subplot(height, width, curVig);
                hold on
                grid on
                for i = 1:numVigs
                    plot([i, i], [0, i-1], ':k');
                end
                
                vignette = vignetteArray(:, :, curVig);
                [vheight, vwidth] = size(vignette);
                for ycoord = 1:vheight
                    for xcoord = 1:vwidth
                        value = vignette(ycoord, xcoord);
                        if ~isnan(value)
                            if value >= 1
                                color1 = 0.95-0.9*(value-1)/(maxHeat-1);
                                color2 = 0.95-0.6*(value-1)/(maxHeat-1);
                                color3 = 0.95-0.3*(value-1)/(maxHeat-1);
                            else
                                color1 = 0.65+0.3*value;
                                color2 = 0.35+0.6*value;
                                color3 = 0.05+0.9*value;
                            end
                            clrAr = [color1 color2 color3];
                            yCenter = ycoord;
                            xCenter = xcoord;
                            
                            squarex = [xCenter-0.5, xCenter-0.5, xCenter+0.5, xCenter+0.5, xCenter-0.5];
                            squarey = [yCenter-0.5, yCenter+0.5, yCenter+0.5, yCenter-0.5, yCenter-0.5];
                            
                            sqr = fill(squarex, squarey, clrAr);
                            set(sqr,'EdgeColor', 'none');
                        end
                    end
                end
                xlim([1.3 vwidth+0.8]);
                xticks(1:1:numVigs);
                ylim([0.3 vheight-0.2]);
                yticks(1:1:numVigs);
                title(strcat('Bug: ', int2str(curVig)));
                hold off
            end
            sgtitle(input('Input a title.\n','s'));
        end
        
        function vigFig = vignettePrintOne(vignette, curVig, numVigs, minHeat, maxHeat)
            vigFig = figure(curVig);
            hold on
            grid on
            for i = 1:numVigs
                plot([i, i], [0, i-1], ':k');
            end
            
            [vheight, vwidth] = size(vignette);
            for ycoord = 1:vheight
                for xcoord = 1:vwidth
                    value = vignette(ycoord, xcoord);
                    if value ~= 0
                        color1 = 0.95-0.9*(value-minHeat)/(maxHeat-minHeat);
                        color2 = 0.95-0.5*(value-minHeat)/(maxHeat-minHeat);
                        color3 = 0.95-0.6*(value-minHeat)/(maxHeat-minHeat);
                        clrAr = [color1 color2 color3];
                        yCenter = ycoord;
                        xCenter = xcoord;
                        
                        squarex = [xCenter-0.5, xCenter-0.5, xCenter+0.5, xCenter+0.5, xCenter-0.5];
                        squarey = [yCenter-0.5, yCenter+0.5, yCenter+0.5, yCenter-0.5, yCenter-0.5];
                        
                        sqr = fill(squarex, squarey, clrAr);
                        set(sqr,'EdgeColor', 'none');
                    end
                end
            end
            xlim([1.3 vwidth+0.8]);
            xticks(1:1:numVigs);
            ylim([0.3 vheight-0.2]);
            yticks(1:1:numVigs);
            title(strcat('Bug: ', int2str(curVig)));
            hold off
        end
        
        function numTris = getCalcNumTris(layout)
            numTris = calcNumTris(layout);
        end
        
        function [combos, max] = getGetParsedCombos(comboTemp)
            [combos, max] = getParsedCombos(comboTemp);
        end
    end
end

function layout = checkArround(checkLay, x, y, xMax, yMax)
% CHECKARROUND Gets values in neighboring wells in the order...
% \n     a b
% \n    c * d
% \n     e f
% \nThis function is easily
    a = 0;
    b = 0;
    c = 0;
    d = 0;
    e = 0;
    f = 0;
    if ((x >= 1) && (x <= xMax) && (y >= 1) && (y <= yMax))
        % The algorithm differs if the row is odd or even
        if (rem(y,2) == 1)
            % Algorithm if odd
            % Checks a, b, and c
            if ((x-1)==0)
                c = 0;
                if ((y-1)==0)
                    a = 0;
                    b = 0;
                else
                    a = checkLay(x,y-1);
                    if (x+1)>xMax
                    b = 0;
                    else
                        b = checkLay(x+1,y-1);
                    end
                end
            else
                c = checkLay(x-1,y);
                if ((y-1)==0)
                    a = 0;
                    b = 0;
                else
                    a = checkLay(x,y-1);
                    if (x+1)>xMax
                    b = 0;
                    else
                        b = checkLay(x+1,y-1);
                    end
                end
            end
            
            % Checks d
            if ((x+1)>xMax)
                d = 0;
            else
                d = checkLay(x+1,y);
            end
            % Checks e and f
            if ((y+1)>yMax)
                e = 0;
                f = 0;
            else
                e = checkLay(x,y+1);
                if ((x+1)>xMax)
                    f = 0;
                else
                    f = checkLay(x+1,y+1);
                end
            end
        else
            % Algorithm if even
            % Checks a and b
            if ((x-1)==0)
                a = 0;
                c = 0;
                b = checkLay(x,y-1);
            else
                a = checkLay(x-1,y-1);
                c = checkLay(x-1,y);
                b = checkLay(x,y-1);
            end

            % Checks d
            if ((x+1)>xMax)
                d = 0;
            else
                d = checkLay(x+1,y);
            end
            % Checks e and f
            if ((y+1)>yMax)
                e = 0;
                f = 0;
            else
                f = checkLay(x,y+1);
                if ((x-1)==0)
                    e = 0;
                else
                    e = checkLay(x-1,y+1);
                end
            end
        end
    end
    layout = [a, b, c, d, e, f];
end

function found = findMatch(matchArray, searchNum)
%FINDMATCH Returns boolean if a sought number is found
    found = 0;
    for i = 1 : 1 : length(matchArray)
        if (matchArray(i) == searchNum)
            found = 1;
        end
    end
end

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

function newArrayID = sortCombos(arrayID)

    for i = 1:length(arrayID)
        smallArray = zeros(3,1);

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

function indivSpec = getIndiv(combo)
    indivSpec = zeros(3,1);
    indivSpec(1,1) = (combo-rem(combo,10000))/10000;
    indivSpec(2,1) = (rem(combo,10000)-rem(combo,100))/100;
    indivSpec(3,1) = rem(combo,100);
end

function numTris = calcNumTris(layout)
    [width height] = size(layout);
    numTris = (width-1)*(height-1)*2;
end

function [combos, max] = getParsedCombos(comboTemp)
    % GETPARSEDCOMBOS returns a list of all combinations observed, without
    % replicates, as well as the maximum number of relicates for a single
    % combination
    combos = zeros();

    comboTemp = sort(comboTemp);

    curCombo = comboTemp(1);
    count = 0;
    comboCount = 1;
    max = 0;
    
    for i = 1:length(comboTemp)
        if comboTemp(i) == curCombo
            count = count+1;
            if count > max
                max = count;
            end
        else
            combos(comboCount) = curCombo;
            comboCount = comboCount+1;
            curCombo = comboTemp(i);
            count = 1;
        end
    end
    
    combos = combos';
end

function  options = findBestChoice(comboList, combo, maxReps)
    %FINDEXISTNGREPS returns an array with the available wells
    options = zeros;
    combo;
    % The first row, first collumn of a device
    if combo(1)==0 && combo(2)==0 && combo(3)==0
        1;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If the number is found, increments its count
                    if sum(comboList(row,1:3)==num)==1 && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end
        
    % First row of a device
    elseif combo(1)==0 && combo(2)==0 && combo(3)~=0
        2;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If already existing number is within the combination,
                    %   and the search number does not equal aready
                    %   existing number, and the mimimum number of reps is
                    %   found, increments the count for that number
                    hasC = sum(comboList(row,1:3)==combo(3));
                    hasNum = sum(comboList(row,1:3)==num);
                    if num~=combo(3) && hasNum==1 && hasC==1 && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end
        
    % First column, even rows
    elseif combo(1)==0 && combo(2)~=0 && combo(3)==0
        3;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If the searc number is found and the existing numbers
                    %   are not, increments count
                    hasB = sum(comboList(row,1:3)==combo(2));
                    hasNum = sum(comboList(row,1:3)==num);
                    if num~=combo(2) && hasNum==1 && hasB==1 && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end
        
    % First column, odd rows
    elseif combo(1)~=0 && combo(2)~=0 && combo(3)==0
        4;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If the searc number is found and the existing numbers
                    %   are not, increments count
                    hasA = sum(comboList(row,1:3)==combo(1));
                    hasB = sum(comboList(row,1:3)==combo(2));
                    hasNum = sum(comboList(row,1:3)==num);
                    if num~=combo(2) && num~=combo(1) && hasNum==1 && hasA==1 && hasB==1 && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end
    elseif combo(1)~=0 && combo(2)==0 && combo(3)~=0
        5;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If the searc number is found and the existing numbers
                    %   are not, increments count
                    hasA = sum(comboList(row,1:3)==combo(1));
                    hasC = sum(comboList(row,1:3)==combo(3));
                    hasNum = sum(comboList(row,1:3)==num);
                    if num~=combo(1) && num~=combo(3) && hasNum==1 && hasA==1 && hasC==1 && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end
    % General Case
    elseif combo(1)~=0 && combo(2)~=0 && combo(3)~=0
        6;
        for reps = 0:maxReps-1
            maxVar = comboList(length(comboList),3);
            maxAvailable = zeros(1, maxVar);
            for num = 1:maxVar
                maxCount = 0;
                for row = 1:length(comboList)
                    % If the searc number is found and the existing numbers
                    %   are not, increments count
                    hasA = sum(comboList(row,1:3)==combo(1));
                    hasB = sum(comboList(row,1:3)==combo(2));
                    hasC = sum(comboList(row,1:3)==combo(3));
                    hasNum = sum(comboList(row,1:3)==num);
                    
                    if combo(2) == combo(3)
                        hasAB = (hasA+hasB==2);
                        hasAC = (hasA+hasC==2);
                    else
                        hasAB = (hasA+hasB==2)&&(hasC==0);
                        hasAC = (hasA+hasC==2)&&(hasB==0);
                    end
                    
                    if num~=combo(1) && num~=combo(2) && num~=combo(3) && hasNum==1 && (hasAB || hasAC) && comboList(row,4) == reps
                        maxCount = maxCount + 1;
                    end
                end
                maxAvailable(num) = maxCount;
            end
            maxVal = max(maxAvailable);
            if maxVal > 0
                options = find(maxAvailable == maxVal, maxVar);
                break;
            end
        end    
    end
end

function comboList = markReps(comboList, neighbors, newNum)

    combo1 = [neighbors(1), neighbors(2), newNum];
    combo2 = [neighbors(1), neighbors(3), newNum];
    combo1 = sort(combo1);
    combo2 = sort(combo2);
    
    % If all entries in the combination are greater than zero, adds the
    %   number to the replicate count
    if sum(combo1 > 0)==3
        for row = 1:length(comboList)
            % If the combination matches, increments the rep count and
            % breaks out of the search loop
            if sum(comboList(row,1:3)==combo1)==3
                comboList(row,4) = comboList(row,4)+1;
                break;
            end
        end
    end
    if sum(combo2 > 0)==3
        for row = 1:length(comboList)
            % If the combination matches, increments the rep count and
            % breaks out of the search loop
            if sum(comboList(row,1:3)==combo2)==3
                comboList(row,4) = comboList(row,4)+1;
                break;
            end
        end
    end
end
    