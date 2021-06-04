function arrayID = getCombos(layout)
    numTris = 88;
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
