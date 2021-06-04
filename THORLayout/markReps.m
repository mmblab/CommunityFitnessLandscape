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