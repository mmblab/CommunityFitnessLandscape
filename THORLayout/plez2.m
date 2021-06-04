function [layout1, layout2, numZeros, comboList] = plez2(posComb)
    found = false;
    count = 1;
    maxCount = 500;
    layout = zeros(12,5);
    numZeros = zeros(1,maxCount);
    
    while ~found && count < maxCount
        comboList = zeros;
        [layout1, comboList] = TriCultureFunc.fillLayoutRandom(layout, posComb, 1);
        [layout2, comboList] = TriCultureFunc.fillLayoutRandom(layout, comboList, 2);
        
        numZeros(count) = sum(comboList(:,4)==0);
        if sum(comboList(:,4) == 0)<=5
            found = true
        end
        
        if rem(count,100) == 0
            count
        end
        count = count +1;
        
    end
    dlmwrite('Layout1of2_LT10.txt',layout1,'delimiter','\t','newline','pc');
    dlmwrite('Layout2of2_LT10.txt',layout2,'delimiter','\t','newline','pc');
end