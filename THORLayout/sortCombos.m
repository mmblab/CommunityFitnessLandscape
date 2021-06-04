function newArrayID = sortCombos(arrayID)

    for i = 1:length(arrayID)
        smallArray = zeros(3,1);

            smallArray(1,1) = (arrayID(i,1)-rem(arrayID(i,1),10000))/10000;
            smallArray(2,1) = (rem(arrayID(i,1),10000)-rem(arrayID(i,1),100))/100;
            smallArray(3,1) = rem(arrayID(i,1),100);
            
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