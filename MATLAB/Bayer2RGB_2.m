function Q=Bayer2RGB_2(IMG)

[h, w] = size(IMG);
win = uint8(zeros(3, 3));
Q = zeros(h, w, 3);

for i=2:h-1
    for j=2:w-1
        if (mod(i,2)==0 && mod(j,2)==0) %center green
            Q(i, j, 1) = (IMG(i, j-1)+IMG(i, j+1)) / 2;
            Q(i, j, 2) = IMG(i, j);
            Q(i, j, 3) = (IMG(i-1, j)+IMG(i+1, j)) / 2;
        elseif (mod(i,2)==0 && mod(j,2)==1) %center red
            Q(i, j, 1) = IMG(i, j);
            Q(i, j, 3) = (IMG(i-1, j-1) + IMG(i+1, j+1) + IMG(i-1, j+1) + IMG(i+1, j-1)) / 4; 
            Q(i, j, 2) = (IMG(i-1, j) + IMG(i, j-1) + IMG(i, j+1) + IMG(i+1, j)) / 4;
        elseif (mod(i,2)==1 && mod(j,2)==0) %center blue
            Q(i, j, 1) = (IMG(i-1, j-1) + IMG(i+1, j+1) + IMG(i-1, j+1) + IMG(i+1, j-1)) / 4; 
            Q(i, j, 2) = (IMG(i-1, j) + IMG(i, j-1) + IMG(i, j+1) + IMG(i+1, j)) / 4;
            Q(i, j, 3) = IMG(i, j);
        else %center green
            Q(i, j, 1) = (IMG(i-1, j)+IMG(i+1, j)) / 2;
            Q(i, j, 2) = IMG(i, j);
            Q(i, j, 3) = (IMG(i, j-1)+IMG(i, j+1)) / 2;
        end

    end
    
end
disp(h);
Q = uint8(Q);