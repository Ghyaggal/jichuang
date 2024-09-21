function Q=Bayer2RGB(IMG)

[h, w] = size(IMG);
win = zeros(3, 3);
Q = zeros(h, w, 3);

for i=1:h
    for j=1:w
        if (i<(n-1)/2+1 || i>h-(n-1)/2 || j<(n-1)/2+1 || j>w-(n-1)/2)
            Q(i, j) = IMG(i, j);
        else
            win = IMG(i-(n-1)/2 : i+(n-1)/2, j-(n-1)/2 : j+(n-1)/2);

            if (win(2,1) > win(2,3)) 
                Data_Hg = win(2,1) - win(2,3);
            else
                Data_Hg = win(2,3) - win(2,1);
            end

            if (win(1,2) > win(3,2)) 
                Data_Vg = win(1,2) - win(3,2);
            else
                Data_Vg = win(3,2) - win(1,2);
            end


            if (win(1, 1) > win(3, 3))
                Data_Drb1 = win(1, 1) - win(3, 3);
            else
                Data_Drb1 = win(3, 3) - win(1, 1);
            end

            if (win(1, 3) > win(3, 1))
                Data_Drb2 = win(1, 3) - win(3, 1);
            else
                Data_Drb2 = win(3, 1) - win(1, 3);
            end


            if (mod(i,2)==0 && mod(j,2)==0) %center green
                Q(i, j, 1) = (win(2, 1)+win(2, 3))/2;
                Q(i, j, 2) = win(2, 2);
                Q(i, j, 3) = (win(1, 2)+win(3, 2))/2;
            elseif (mod(i,2)==0 && mod(j,2)==1) %center red
                Q(i, j, 1) = win(2, 2);

                if (Data_Drb1 < Data_Drb2)
                    Q(i, j, 3) = (win(1, 1) + win(3, 3))/2;
                elseif (Data_Drb1 > Data_Drb2)
                    Q(i, j, 3) = (win(1, 3) + win(3, 1))/2; 
                else
                    Q(i, j, 3) = (win(1, 1) + win(3, 3) + win(1, 3) + win(3, 1))/4; 
                end
                if (Data_Hg < Data_Vg)
                    Q(i, j, 2) = (win(2, 1) + win(2, 3))/2;
                elseif (Data_Hg > Data_Vg)
                    Q(i, j, 2) = (win(1, 2) + win(3, 2))/2;
                else
                    Q(i, j, 2) = (win(1, 2) + win(2, 1) + win(2, 3) + win(3, 2))/4;
                end

            elseif (mod(i,2)==1 && mod(j,2)==0) %center blue
                
                if (Data_Drb1 < Data_Drb2)
                    Q(i, j, 1) = (win(1, 1) + win(3, 3))/2;
                elseif (Data_Drb1 > Data_Drb2)
                    Q(i, j, 1) = (win(1, 3) + win(3, 1))/2; 
                else
                    Q(i, j, 1) = (win(1, 1) + win(3, 3) + win(1, 3) + win(3, 1))/4; 
                end

                if (Data_Hg < Data_Vg)
                    Q(i, j, 2) = (win(2, 1) + win(2, 3))/2;
                elseif (Data_Hg > Data_Vg)
                    Q(i, j, 2) = (win(1, 2) + win(3, 2))/2;
                else
                    Q(i, j, 2) = (win(1, 2) + win(2, 1) + win(2, 3) + win(3, 2))/4;
                end
                Q(i, j, 3) = win(2, 2);
            else %center green
                Q(i, j, 1) = (win(1, 2)+win(3, 2))/2;
                Q(i, j, 2) = win(2, 2);
                Q(i, j, 3) = (win(2, 1)+win(2, 3))/2;
            end
        end

    end
    
end

Q = uint8(Q);