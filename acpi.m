clear all, clc;
% ----------------------------------------
%           octave need load pkg
% ----------------------------------------
% pkg load image  

origin = imread('lena_128x128.bmp');
origin = double(origin);
Red_o = origin(:,:,1);
Green_o = origin(:,:,2);
Blue_o = origin(:,:,3);

lena_dat = textread('lena_128x128_bayer_cfa.dat','%q');
lena_dat = hex2dec(lena_dat);
lena_dat = reshape(lena_dat,[],128);
lena_dat = lena_dat';
[lena_xi,lena_xj] = size(lena_dat);

Green_hw = textread('green.dat','%q');
Green_hw = hex2dec(Green_hw);
Green_hw = reshape(Green_hw,[],128);
Green_hw = Green_hw';
Blue_hw = textread('blue.dat','%q');
Blue_hw = hex2dec(Blue_hw);
Blue_hw = reshape(Blue_hw,[],128);
Blue_hw = Blue_hw';
Red_hw = textread('red.dat','%q');
Red_hw = hex2dec(Red_hw);
Red_hw = reshape(Red_hw,[],128);
Red_hw = Red_hw';

lena_x = zeros(lena_xi,lena_xj);

% -----------------------------------------------
%               fill original R,G,B 
% -----------------------------------------------

Green = zeros(lena_xi,lena_xj);
Blue = zeros(lena_xi,lena_xj);
Red = zeros(lena_xi,lena_xj);
Green_1 = zeros(lena_xi,lena_xj);
Blue_1 = zeros(lena_xi,lena_xj);
Red_1 = zeros(lena_xi,lena_xj);

for i = 1 : 2 : lena_xi
    for j = 1 : 2 : lena_xj
        Green_1(i,j) = lena_dat(i,j);
    end
end

for i = 2 : 2 : lena_xi
    for j = 2 : 2 : lena_xj
        Green_1(i,j) = lena_dat(i,j);
    end
end

for i = 1 : 2 : lena_xi
    for j = 2 : 2 : lena_xj
        Red_1(i,j) = lena_dat(i,j);
    end
end

for i = 2 : 2 : lena_xi
    for j = 1 : 2 : lena_xj
        Blue_1(i,j) = lena_dat(i,j);
    end
end

for i = 1 : lena_xi 
    for j = 1 : lena_xj 
	lena_x(i,j) = lena_dat(i,j);
        Green(i,j) = lena_dat(i,j);
        Blue(i,j) = lena_dat(i,j);
        Red(i,j) = lena_dat(i,j);
    end
end

for i = 1 : 1 : lena_xi
    for j = 1 : 1 : lena_xj
        Green_hw(i,j) = Green_hw(i,j) / 8;
    end
end

for i = 1 : 2 : lena_xi
    for j = 1 : 2 : lena_xj
        Green_hw(i,j) = lena_dat(i,j);
    end
end

for i = 2 : 2 : lena_xi
    for j = 2 : 2 : lena_xj
        Green_hw(i,j) = lena_dat(i,j);
    end
end

for i = 1 : 1 : lena_xi
    for j = 1 : 1 : lena_xj
        Blue_hw(i,j) = Blue_hw(i,j) / 4;
    end
end

for i = 2 : 2 : lena_xi
    for j = 1 : 2 : lena_xj
        Blue_hw(i,j) = lena_dat(i,j);
    end
end

for i = 1 : 1 : lena_xi
    for j = 1 : 1 : lena_xj
        Red_hw(i,j) = Red_hw(i,j) / 4;
    end
end

for i = 1 : 2 : lena_xi
    for j = 2 : 2 : lena_xj
        Red_hw(i,j) = lena_dat(i,j);
    end
end

% ------------------------------------------------------------
%                 Matrix mirror fill the edge
% ------------------------------------------------------------

lena = [lena_x(2:-1:1,:); lena_x; lena_x(end:-1:end-(2-1), :)];
lena = [lena(:, 2:-1:1), lena, lena(:, end:-1:end-(2-1))];

[lena_i,lena_j] = size(lena);

% ------------------------------------------------------
%               Green interpolation by Red 
% ------------------------------------------------------

for i = 3 : 2 : lena_i-3
    for j = 4 : 2 : lena_j-2 
        DH = abs(lena(i,j-1) - lena(i,j+1)) + abs((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2));
        DV = abs(lena(i-1,j) - lena(i+1,j)) + abs((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j));
        if DH < DV
            Green(i-2,j-2) = ((lena(i,j-1) + lena(i,j+1))/2) + (((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2))/4);
        elseif DV < DH
            Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j))/2) + (((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j))/4);
        else
            Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j) + lena(i,j-1) + lena(i,j+1))/4) + (((4*lena(i,j)) - lena(i-2,j) - lena(i+2,j) - lena(i,j-2) - lena(i,j+2))/8);
        end
    end
end

% -------------------------------------------------------
%               Green interpolation by Blue 
% -------------------------------------------------------

for i = 4 : 2 : lena_i - 2 
    for j = 3 : 2 : lena_j - 3 
        DH = abs(lena(i,j-1) - lena(i,j+1)) + abs((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2));
    	DV = abs(lena(i-1,j) - lena(i+1,j)) + abs((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j));
    	if DH < DV
    		Green(i-2,j-2) = ((lena(i,j-1) + lena(i,j+1))/2) + (((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2))/4);
    	elseif DV < DH
    		Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j))/2) + (((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j))/4);
        else
    		Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j) + lena(i,j-1) + lena(i,j+1))/4) + (((4*lena(i,j)) - lena(i-2,j) - lena(i+2,j) - lena(i,j-2) - lena(i,j+2))/8);
        end
    end
end

% ---------------------------------------------------------------------
%     Green matrix mirror fill the edge, for the blue, red required    
% ---------------------------------------------------------------------

Green_mirror = [Green(2:-1:1,:); Green; Green(end:-1:end-(2-1), :)];
Green_mirror = [Green_mirror(:, 2:-1:1), Green_mirror, Green_mirror(:, end:-1:end-(2-1))];

% -------------------------------------------------------
%               Blue interpolation by Green
% -------------------------------------------------------

for i = 3 : 2 : lena_i - 3
    for j = 4 : 2 : lena_j - 2 
        Blue(i+1-2,j-2) = ((lena(i+1,j-1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i+1,j) - Green_mirror(i+1,j-1) - Green_mirror(i+1,j+1))/2); %B11
    	Blue(i-2,j-1-2) = ((lena(i-1,j-1) + lena(i+1,j-1))/2) + ((2*Green_mirror(i,j-1) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j-1))/2); %B6
        
    	DN = abs(lena(i-1,j-1) - lena(i+1,j+1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1));
    	DP = abs(lena(i-1,j+1) - lena(i+1,j-1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1));
    	if DN < DP
     		Blue(i-2,j-2) = ((lena(i-1,j-1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/2);
    	elseif DP < DN
    		Blue(i-2,j-2) = ((lena(i-1,j+1) + lena(i+1,j-1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1))/2);
        else
     		Blue(i-2,j-2) = ((lena(i-1,j-1) + lena(i-1,j+1) + lena(i+1,j-1) + lena(i+1,j+1))/4) + ((4*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/4);
        end
    end
end

% -------------------------------------------------------
%               Red interpolation by Green 
% -------------------------------------------------------

for i = 4 : 2 : lena_i - 2
    for j = 3 : 2 : lena_j - 3
    	Red(i-1-2,j-2) = ((lena(i-1,j-1) + lena(i-1,j+1))/2) + ((2*Green_mirror(i-1,j) - Green_mirror(i-1,j-1) - Green_mirror(i-1,j+1))/2); %R3 
        Red(i-2,j+1-2) = ((lena(i-1,j+1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i,j+1) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j+1))/2); %R8
	
    	DC = abs(lena(i-1,j-1) - lena(i+1,j+1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1));
        DK = abs(lena(i-1,j+1) - lena(i+1,j-1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1));
    	if DC < DK
    		Red(i-2,j-2) = ((lena(i-1,j-1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/2);
    	elseif DK < DC
    		Red(i-2,j-2) = ((lena(i-1,j+1) + lena(i+1,j-1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1))/2);
        else
    		Red(i-2,j-2) = ((lena(i-1,j-1) + lena(i-1,j+1) + lena(i+1,j-1) + lena(i+1,j+1))/4) + ((4*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/4);
    	end
    end
end

% ------------------------------------------
%               Calculate PSNR
% ------------------------------------------

MSE_R_sw = sum(sum((Red_o - Red).^2)) / (lena_xi * lena_xj);
PSNR_R_sw = 10 * log10((255^2) / MSE_R_sw );                                                        

MSE_G_sw = sum(sum((Green_o - Green).^2)) / (lena_xi * lena_xj);
PSNR_G_sw = 10 * log10((255^2) / MSE_G_sw );                                                        

MSE_B_sw = sum(sum((Blue_o - Blue).^2)) / (lena_xi * lena_xj);
PSNR_B_sw = 10 * log10((255^2) / MSE_B_sw );                                                        

MSE_R_hw = sum(sum((Red_o - Red_hw).^2)) / (lena_xi * lena_xj);
PSNR_R_hw = 10 * log10((255^2) / MSE_R_hw );                                                        

MSE_G_hw = sum(sum((Green_o - Green_hw).^2)) / (lena_xi * lena_xj);
PSNR_G_hw = 10 * log10((255^2) / MSE_G_hw );                                                        

MSE_B_hw = sum(sum((Blue_o - Blue_hw).^2)) / (lena_xi * lena_xj);
PSNR_B_hw = 10 * log10((255^2) / MSE_B_hw );                                                        


figure(1);
subplot(2,4,1),imshow(uint8(Red));
subplot(2,4,2),imshow(uint8(Green));
subplot(2,4,3),imshow(uint8(Blue));
Image(:,:,1) =Red;
Image(:,:,2) =Green;
Image(:,:,3) =Blue;
subplot(2,4,4),imshow(uint8(Image));

subplot(2,4,5),imshow(uint8(Red_hw));
subplot(2,4,6),imshow(uint8(Green_hw));
subplot(2,4,7),imshow(uint8(Blue_hw));
Image_hw(:,:,1) =Red_hw;
Image_hw(:,:,2) =Green_hw;
Image_hw(:,:,3) =Blue_hw;
subplot(2,4,8),imshow(uint8(Image_hw));

figure(2);
bayer(:,:,1) = Red_1;
bayer(:,:,2) = Green_1;
bayer(:,:,3) = Blue_1;
subplot(1,3,1),imshow(uint8(bayer));
subplot(1,3,2),imshow(uint8(Image_hw));
subplot(1,3,3),imshow(uint8(Image));
