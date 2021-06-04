function  options = findExistingReps(comboList, combo, maxReps)
    %FINDEXISTNGREPS returns an array with the available wells
    options = zeros;
    
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
                    if num~=combo(3) && hasNum==1 && hasC==1 && comboList(row,4) < reps
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
        6
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
                        1
                        hasAB = (hasA+hasB==2);
                        hasAC = (hasA+hasC==2);
                    else
                        2
                        hasAB = (hasA+hasB==2)&&(hasC==0);
                        hasAC = (hasA+hasC==2)&&(hasB==0);
                    end
                    
                    if num~=combo(1) && num~=combo(2) && num~=combo(3) && hasNum==1 && comboList(row,4)==reps && (comboList(row,4)<maxReps) && (hasAB || hasAC)
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