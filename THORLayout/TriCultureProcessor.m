%% THOR? Layout Generator and Data Processor
%   Will Wightman - MMB Labs - 2019/06/10
%       Last Edit:  2019/06/11
%
%       This program is the first of a two part program...
%       1. This program generates the best possible random layout for a 
%           given number of variable wells.
%       2. It compliment takes the data returned from Image J (as of now)
%           and organizesit for easier workability.
%% Select Mode
% Prompts the user to select wether or not they wish to generate a layout
%   or analyse data gathered from a specific layout. 
% If they choose to generate, they can generate a random layout or load a
%   presaved layout.
% If they choose to analyse, the user will be required to input the
%   filename of the layout, and the filename of the associated image or 
%   data file to be analysed.
filepath = pwd;
prompt = 'Would you like to generate or analyse a data file(G/A)?\n';
gen = input(prompt, 's');
if gen == 'g' || gen == 'G'
    %% Generate Layout
    %   Random
    %       Randomly generates multiple possible layouts based on the
    %       number of variable wells desired. The number of combinations
    %       possible are calculated from the number of desired variable
    %       wells, and the average number of repeats for each combination
    %       is calculated.
    %       
    %       Multiple boards are then randomly generated and the number of
    %       each combination in the layout are then counted. The board that
    %       has the best average replicates and ideally at least one
    %       replicate per combination is selected as the final layout.
    %   
    %   Load File
    %       Loads a layout from a text file and generates an image file and
    %       another text file.

    % Layout Constants
      % Maximum boundaries of layout
        layXMax = 12;
        layYMax = 5;
      % Max number ouf layouts to test
        testMax = 500;
        numTris = 2*(layXMax-1)*(layYMax-1);

    prompt = 'Would you like to generate a random layout or  load a layout from file(R/L)?\n';
    mode = input(prompt, 's');
    if mode == 'R' || mode == 'r'
        % Gets user input for the number of variable wells
        desiredInput = false;
        while (desiredInput == false)

            % Prompts for how many variable wells the user wishes to use
            promptNumVars = 'How many variable bacteria samples do you wish to test?\n';
            numVars       = input(promptNumVars);

            % This loop calculates the number of possible combinations for
            % a given number of variable wells.
            numCombos = TriCultureFunc.calcCombos(numVars);

            % Prompts the userwith the current number of combinations
            % possible and asks user is they wish to continue
            prompCont01 = 'There are-';
            prompCont01 = strcat(prompCont01, num2str(numCombos));
            prompCont01 = strcat(prompCont01, ' combinations.\nChange input?(Y/N)\n');
            cont = input(prompCont01, 's');

            if (cont == 'N' || cont == 'n')
                desiredInput = true;
            end
        end

        % Randomly generates layouts and calculates stats for each layout
        if numVars <=4
            testMax = 13;
        end
        manyLayouts = zeros(testMax, layXMax, layYMax);
        manyStats = zeros(testMax, 3);
        for i = 1:testMax
            layout = TriCultureFunc.fillRandom(numVars, layXMax, layYMax);
            for j = 1:layXMax
                for k = 1:layYMax
                    manyLayouts(i,j,k) = layout(j,k);
                end
            end
            [manyStats(1,i),manyStats(2,i),manyStats(3,i)] = TriCultureFunc.comboStats(layout, numCombos);
        end

        index = TriCultureFunc.findBest(manyStats);
        for i = 1:layXMax
            for j = 1:layYMax
                layout (j,k) = manyLayouts(index,j,k);
            end
        end
    else
        layout = TriCultureFunc.importLayout('Select a layout...');
    end

    layoutToSave = TriCultureFunc.printLayout(layout);

    % Prompts user to save layout
    prompt = 'Would you like to save this layout?\n';

    cont = input(prompt, 's');

    if cont == 'Y' || cont == 'y'
        TriCultureFunc.exportLayout(layoutToSave,layout);
    end
else
    %% Analyse Data
    %   This segment allows the user to analyse data. Thes user can import
    %       a file storing premeasured values, MAYBE analyse a image
    %       directtly.
    
    % Gets howmany devices/layouts need to be processed
    numDevices = input('How many devices are a part of this layout?\n');
    for i = 1:numDevices
        if i > 1
        [dataByTriTemp, layoutTemp, filepath] = TriCultureFunc.agrigateData(filepath);
        dataByTriTemp.Index = dataByTriTemp.Index + max(dataByTri.Index, [], 'all');
        dataByTri = [dataByTri; dataByTriTemp];
        layout(:,:,i) = layoutTemp;
        else 
            [dataByTri, layout(:,:,i), filepath] = TriCultureFunc.agrigateData(filepath);
        end
    end
    
    %[dataByBug dataByBugSimple] = TriCultureFunc.organizeByBug(dataByTri);
    
    save = input('Would you like to save dataByTri file(Y/N)?\n', 's');
    
    if save == 'Y' || save == 'y'
        filepath = TriCultureFunc.exportTable(dataByTri,filepath);
    end
    
    vigYes = input('Would you like to generate vignettes (Y/N)?','s');
    
    if vigYes
        vigtri = TriCultureFunc.vignetteGen(dataByTri, false);
        vigcorn = TriCultureFunc.vignetteGen(dataByTri, true);
        absolute = TriCultureFunc.vignettePrintAll(vigtri);
        delta = TriCultureFunc.vignettePrintAll(vigtri,vigcorn);
    end
%     save = input('Would you like to save dataByBug file(Y/N)?\n', 's');
%     
%     if save == 'Y' || save == 'y'
%         TriCultureFunc.exportTable(dataByBug);
%     end
end