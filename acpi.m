clear all, clc;
% ----------------------------------------
% --------- octave need load pkg ---------
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

Green_1 = textread('green.dat','%q');
Green_1 = hex2dec(Green_1);
Green_1 = reshape(Green_1,[],128);
Green_1 = Green_1';
Blue_1 = textread('blue.dat','%q');
Blue_1 = hex2dec(Blue_1);
Blue_1 = reshape(Blue_1,[],128);
Blue_1 = Blue_1';
Red_1 = textread('red.dat','%q');
Red_1 = hex2dec(Red_1);
Red_1 = reshape(Red_1,[],128);
Red_1 = Red_1';

lena_x = zeros(lena_xi,lena_xj);

% -----------------------------------------------
% ------------- fill original R,G,B -------------
% -----------------------------------------------

Green = zeros(lena_xi,lena_xj);
Blue = zeros(lena_xi,lena_xj);
Red = zeros(lena_xi,lena_xj);

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
        Green_1(i,j) = Green_1(i,j) / 8;
    end
end

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

for i = 1 : 1 : lena_xi
    for j = 1 : 1 : lena_xj
        Blue_1(i,j) = Blue_1(i,j) / 4;
    end
end

for i = 2 : 2 : lena_xi
    for j = 1 : 2 : lena_xj
        Blue_1(i,j) = lena_dat(i,j);
    end
end

for i = 1 : 1 : lena_xi
    for j = 1 : 1 : lena_xj
        Red_1(i,j) = Red_1(i,j) / 4;
    end
end

for i = 1 : 2 : lena_xi
    for j = 2 : 2 : lena_xj
        Red_1(i,j) = lena_dat(i,j);
    end
end

% ------------------------------------------------------------
% --------------- Matrix mirror fill the edge ----------------
% ------------------------------------------------------------

lena = [lena_x(2:-1:1,:); lena_x; lena_x(end:-1:end-(2-1), :)];
lena = [lena(:, 2:-1:1), lena, lena(:, end:-1:end-(2-1))];

[lena_i,lena_j] = size(lena);

% ------------------------------------------------------
% ------------- Green interpolation by Red -------------
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
% ------------- Green interpolation by Blue -------------
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
% --- Green matrix mirror fill the edge, for the blue, red required ---
% ---------------------------------------------------------------------

Green_mirror = [Green(2:-1:1,:); Green; Green(end:-1:end-(2-1), :)];
Green_mirror = [Green_mirror(:, 2:-1:1), Green_mirror, Green_mirror(:, end:-1:end-(2-1))];

% -------------------------------------------------------
% ------------- Blue interpolation by Green -------------
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
% ------------- Red interpolation by Green --------------
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
% ------------- Calculate PSNR -------------
% ------------------------------------------

MSE_R = sum(sum((Red_o - Red_1).^2)) / (lena_xi * lena_xj);
if  MSE_R == 0
    PSNR_R = 200;
else
    PSNR_R = 10 * log10((255^2) / MSE_R );                                                        
end

MSE_G = sum(sum((Green_o - Green_1).^2)) / (lena_xi * lena_xj);
if  MSE_G == 0
    PSNR_G = 200;
else
    PSNR_G = 10 * log10((255^2) / MSE_G );                                                        
end

MSE_B = sum(sum((Blue_o - Blue_1).^2)) / (lena_xi * lena_xj);
if  MSE_B == 0
    PSNR_B = 200;
else
    PSNR_B = 10 * log10((255^2) / MSE_B );                                                        
end

figure(1);
subplot(2,4,1),imshow(uint8(Red));
subplot(2,4,2),imshow(uint8(Green));
subplot(2,4,3),imshow(uint8(Blue));
Image(:,:,1) =Red;
Image(:,:,2) =Green;
Image(:,:,3) =Blue;
subplot(2,4,4),imshow(uint8(Image));

subplot(2,4,5),imshow(uint8(Red_1));
subplot(2,4,6),imshow(uint8(Green_1));
subplot(2,4,7),imshow(uint8(Blue_1));
Image1(:,:,1) =Red_1;
Image1(:,:,2) =Green_1;
Image1(:,:,3) =Blue_1;
subplot(2,4,8),imshow(uint8(Image1));

figure(2);
subplot(1,3,1),imshow(uint8(lena_dat));
subplot(1,3,2),imshow(uint8(Image1));
subplot(1,3,3),imshow(uint8(Image));
