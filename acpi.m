clear all, clc;

% pkg load image; % ----- octave need load image package ----- 

lena_dat = textread('lena_128x128_bayer_cfa.dat','%q');
lena_dat = hex2dec(lena_dat);
lena_dat = reshape(lena_dat,[],128);
lena_dat = lena_dat';
[lena_xi,lena_xj] = size(lena_dat);

lena_x = zeros(lena_xi,lena_xj);

% ---------------------------------------------
% ------------- 將原本的R、G、B補齊 -------------
% ---------------------------------------------

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

% ------------------------------------------------------------
% ------------- 矩陣鏡射補齊邊緣，取代用補零的方式 --------------
% ------------------------------------------------------------

lena = [lena_x(2:-1:1,:); lena_x; lena_x(end:-1:end-(2-1), :)];
lena = [lena(:, 2:-1:1), lena, lena(:, end:-1:end-(2-1))];

[lena_i,lena_j] = size(lena);

% ------------------------------------
% ------------- 由紅算綠 --------------
% ------------------------------------

for i = 3 : 2 : lena_i-3
	for j = 4 : 2 : lena_j-2 
        DH = abs(lena(i,j-1) - lena(i,j+1)) + abs((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2));
        DV = abs(lena(i-1,j) - lena(i+1,j)) + abs((2*lena(i,j)) - lena(i-1,j) - lena(i+2,j));
        if DH < DV
            Green(i-2,j-2) = ((lena(i,j-1) + lena(i,j+1))/2) + (((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2))/4);
        elseif DV < DH
            Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j))/2) + (((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j))/4);
        else
            Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j) + lena(i,j-1) + lena(i,j+1))/4) + (((4*lena(i,j)) - lena(i-1,j) - lena(i+2,j) - lena(i,j-2) - lena(i,j+2))/8);
        end
    end
end

% ------------------------------------
% ------------- 由藍算綠 --------------
% ------------------------------------

for i = 4 : 2 : lena_i - 2 
	for j = 3 : 2 : lena_j - 3 
		DH = abs(lena(i,j-1) - lena(i,j+1)) + abs((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2));
		DV = abs(lena(i-1,j) - lena(i+1,j)) + abs((2*lena(i,j)) - lena(i-1,j) - lena(i+2,j));
		if DH < DV
			Green(i-2,j-2) = ((lena(i,j-1) + lena(i,j+1))/2) + (((2*lena(i,j)) - lena(i,j-2) - lena(i,j+2))/4);
		elseif DV < DH
			Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j))/2) + (((2*lena(i,j)) - lena(i-2,j) - lena(i+2,j))/4);
		else
			Green(i-2,j-2) = ((lena(i-1,j) + lena(i+1,j) + lena(i,j-1) + lena(i,j+1))/4) + (((4*lena(i,j)) - lena(i-1,j) - lena(i+2,j) - lena(i,j-2) - lena(i,j+2))/8);
        end
	end
end

% ------------------------------------------------------------
% ------------- 綠色鏡射補齊邊緣，以供算藍、紅所需 --------------
% ------------------------------------------------------------

Green_mirror = [Green(2:-1:1,:); Green; Green(end:-1:end-(2-1), :)];
Green_mirror = [Green_mirror(:, 2:-1:1), Green_mirror, Green_mirror(:, end:-1:end-(2-1))];

% ------------------------------------
% ------------- 由綠算藍 --------------
% ------------------------------------

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

% ------------------------------------
% ------------- 由綠算紅 --------------
% ------------------------------------

for i = 4 : 2 : lena_i - 2
	for j = 3 : 2 : lena_j - 3  
		DC = abs(lena(i-1,j-1) - lena(i+1,j+1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1));
		DK = abs(lena(i-1,j+1) - lena(i+1,j-1)) + abs(2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1));
		if DC < DK
			Red(i-2,j-2) = ((lena(i-1,j-1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/2);
		elseif DK < DC
			Red(i-2,j-2) = ((lena(i-1,j+1) + lena(i+1,j-1))/2) + ((2*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1))/2);
		else
			Red(i-2,j-2) = ((lena(i-1,j-1) + lena(i-1,j+1) + lena(i+1,j-1) + lena(i+1,j+1))/4) + ((4*Green_mirror(i,j) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j-1) - Green_mirror(i-1,j-1) - Green_mirror(i+1,j+1))/4);
		end

 		Red(i-1-2,j-2) = ((lena(i-1,j-1) + lena(i-1,j+1))/2) + ((2*Green_mirror(i-1,j) - Green_mirror(i-1,j-1) - Green_mirror(i-1,j+1))/2); %R3
 
 		Red(i-2,j+1-2) = ((lena(i-1,j+1) + lena(i+1,j+1))/2) + ((2*Green_mirror(i+1,j+1) - Green_mirror(i-1,j+1) - Green_mirror(i+1,j+1))/2); %R8
	end
end

subplot(1,4,1),imshow(uint8(Red));
subplot(1,4,2),imshow(uint8(Green));
subplot(1,4,3),imshow(uint8(Blue));
Image(:,:,1) = Red;
Image(:,:,2) = Green;
Image(:,:,3) = Blue;
subplot(1,4,4),imshow(uint8(Image));
