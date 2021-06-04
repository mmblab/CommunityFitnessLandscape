tempArray = zeros(12,5);
count = 0;
for i = 1:12
    for j = 1:5
        tempArray(i,j) = rem(count, 11) + 1;
        count = count + 1;
    end
end