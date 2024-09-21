clc;
clear;

I = imread("1.jpg");
figure,imshow(I);

[ih, iw, chan] = size(I);
disp(ih);
img = uint8(zeros(ih,iw));

for i=1:ih
    for j=1:iw
        if ((mod(i,2)==1) && (mod(j,2)==0))
            img(i, j) = I(i, j, 3);
        elseif ((mod(i,2)==0) && (mod(j,2)==1))
            img(i, j) = I(i, j, 1);
        else
            img(i, j) = I(i, j, 2);
        end
    end
end

figure,imshow(img);



bayerPadding = zeros(ih,iw);
bayerPadding(1:ih, 1:iw) = uint8(img);
imDst = zeros(ih, iw, chan);


for ver = 1:ih
    for hor = 1:iw
        if ((ver==1) || (hor==1) || (ver==ih) || (hor==iw))
            imDst(ver,hor,1) = bayerPadding(ver,hor);
            imDst(ver,hor,2) = bayerPadding(ver,hor);
            imDst(ver,hor,3) = bayerPadding(ver,hor);
        else
            Data_Hg = uint8(abs(bayerPadding(ver, hor-1) - bayerPadding(ver, hor+1)));
            Data_Vg = uint8(abs(bayerPadding(ver-1, hor) - bayerPadding(ver+1, hor)));
            Data_Drb1 = uint8(abs(bayerPadding(ver-1, hor-1) - bayerPadding(ver+1, hor+1)));
            Data_Drb2 = uint8(abs(bayerPadding(ver-1, hor+1) - bayerPadding(ver+1, hor-1)));
            if(1 == mod(ver,2))
                if(1 == mod(hor,2))
                    imDst(ver,hor,2) = bayerPadding(ver,hor);
                    imDst(ver,hor,1) = (bayerPadding(ver-1,hor) + bayerPadding(ver+1,hor)) / 2;
                    imDst(ver,hor,3) = (bayerPadding(ver,hor-1) + bayerPadding(ver,hor+1)) / 2;
                else
                    imDst(ver,hor,3) = bayerPadding(ver,hor);
    
                    if (Data_Hg < Data_Vg)
                        imDst(ver,hor,2) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1)) / 2;
                    elseif (Data_Hg > Data_Vg)
                        imDst(ver,hor,2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor)) / 2;
                    else
                        imDst(ver,hor,2) = (bayerPadding(ver-1,hor) + bayerPadding(ver,hor-1) + bayerPadding(ver,hor+1) + bayerPadding(ver+1,hor)) / 4;
                    end
    
                    if (Data_Drb1 < Data_Drb2)
                        imDst(ver,hor,1) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver+1, hor+1)) / 2;
                    elseif (Data_Drb1 > Data_Drb2)
                        imDst(ver,hor,1) = (bayerPadding(ver-1, hor+1) + bayerPadding(ver+1, hor-1)) / 2;
                    else
                        imDst(ver,hor,1) = (bayerPadding(ver-1,hor-1) + bayerPadding(ver-1,hor+1) + bayerPadding(ver+1,hor-1) + bayerPadding(ver+1,hor+1)) / 4;
                    end
                end
            else
                if(1 == mod(hor,2))
                    imDst(ver,hor,1) = bayerPadding(ver,hor);
                    if (Data_Hg < Data_Vg)
                        imDst(ver,hor,2) = (bayerPadding(ver, hor-1) + bayerPadding(ver, hor+1)) / 2;
                    elseif (Data_Hg > Data_Vg)
                        imDst(ver,hor,2) = (bayerPadding(ver-1, hor) + bayerPadding(ver+1, hor)) / 2;
                    else
                        imDst(ver,hor,2) = (bayerPadding(ver-1,hor) + bayerPadding(ver,hor-1) + bayerPadding(ver,hor+1) + bayerPadding(ver+1,hor)) / 4;
                   end
                   if (Data_Drb1 < Data_Drb2)
                        imDst(ver,hor,3) = (bayerPadding(ver-1, hor-1) + bayerPadding(ver+1, hor+1)) / 2;
                    elseif (Data_Drb1 > Data_Drb2)
                        imDst(ver,hor,3) = (bayerPadding(ver-1, hor+1) + bayerPadding(ver+1, hor-1)) / 2;
                    else
                        imDst(ver,hor,3) = (bayerPadding(ver-1,hor-1) + bayerPadding(ver-1,hor+1) + bayerPadding(ver+1,hor-1) + bayerPadding(ver+1,hor+1)) / 4;
                   end
                else
                    imDst(ver,hor,2) = bayerPadding(ver,hor);
                    imDst(ver,hor,1) = (bayerPadding(ver,hor-1) + bayerPadding(ver,hor+1)) / 2;
                    imDst(ver,hor,3) = (bayerPadding(ver-1,hor) + bayerPadding(ver+1,hor)) / 2;
                end
            end
        end
    end
end

imDst = uint8(fix(imDst));
figure,imshow(imDst);
imwrite(img,'test.jpg');

Gray2Gray_Data_Gen(bayerPadding, imDst(:,:,3));

