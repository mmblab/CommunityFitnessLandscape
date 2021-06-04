function [layout1, layout2, layout3, comboList1, comboList2, comboList3] = plez(posComb)
    found = false;
    count = 0;
    maxCount = 100000;
    layout = zeros(12,5);
    
    while ~found && count < maxCount
        comboList3 = zeros;
        [layout1, comboList1] = TriCultureFunc.fillLayoutRandom(layout, posComb, 1);
        if layout1(1,1) > 0
            [layout2, comboList2] = TriCultureFunc.fillLayoutRandom(layout, comboList1, 2);
            if layout2(1,1) > 0
                [layout3, comboList3] = TriCultureFunc.fillLayoutRandom(layout, comboList2, 2);
            end
        end
        
        if sum(comboList3(:,4) == 0)<=5
            found = true
        end
        
        if rem(count,100) == 0
            count
        end
        count = count +1;
        
    end
    dlmwrite('Layout1of3.txt',layout1,'delimiter','\t','newline','pc');
    dlmwrite('Layout2of3.txt',layout2,'delimiter','\t','newline','pc');
    dlmwrite('Layout3of3.txt',layout3,'delimiter','\t','newline','pc');
end