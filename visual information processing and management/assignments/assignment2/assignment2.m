clear all;
close all;

flash = im2double(imread('giantShadowFlash.jpg'));
no_flash = im2double(imread('giantShadowNo-flash.jpg'));

figure
subplot(1,2,1), imshow(flash), title('Flash image');
subplot(1,2,2), imshow(no_flash), title('No flash image');

% Diagonal length
diag_len = (size(flash, 1)^2 + size(flash, 2)^2)^0.5;

%% Colour decoupling

weights = flash ./ sum(flash, 3);
c = 1 / log10(2);

I_f = sum(weights .* flash, 3);
% I_f = rgb2ycbcr(flash);
% I_f = mat2gray(I_f(:, :, 1));
% I_f = 1/3 * sum(flash, 3);
I_f = c .* log10(I_f + 1);
C_f = c .* log10(flash + 1) ./ I_f;

I_nf = sum(weights .* no_flash, 3);
% I_nf = rgb2ycbcr(no_flash);
% I_nf = mat2gray(I_nf(:, :, 1));
% I_nf = 1/3 * sum(no_flash, 3);
I_nf = c .* log10(I_nf + 1);
C_nf = c .* log10(no_flash + 1) - I_nf;

%% Compute large scale images with a bilateral filtering

% LS_f = bfilter2(c * log10(I_f + 1), 1, [0.015 * diag_len 0.4]);
% LS_nf = bfilter2(c * log10(I_nf + 1), 1, [0.015 * diag_len 0.4]);
%  
% LS_f = imbilatfilt(c * log10(I_f + 1), 0.4, 0.015 * diag_len);
% LS_nf = imbilatfilt(c * log10(I_nf + 1), 0.4, 0.015 * diag_len);
% 
[ LS_f , ~ ]  =  shiftableBF(c * log10(I_f + 1), 0.015 * diag_len, 0.4);
[ LS_nf , ~ ]  =  shiftableBF(c * log10(I_nf + 1), 0.015 * diag_len, 0.4);
% 
% LS_f = bfilter2(I_f, 1, [0.015 * diag_len 0.4]);
% LS_nf = bfilter2(I_nf, 1, [0.015 * diag_len 0.4]);
%  
% LS_f = imbilatfilt(I_f, 0.4, 0.015 * diag_len);
% LS_nf = imbilatfilt(I_nf, 0.4, 0.015 * diag_len);
% 
% [ LS_f , ~ ]  =  shiftableBF(I_f, 0.015 * diag_len, 0.4);
% [ LS_nf , ~ ]  =  shiftableBF(I_nf, 0.015 * diag_len, 0.4);

%% Compute details

% D_f = I_f ./ LS_f;
% D_nf = I_nf ./ LS_nf;

D_f = mat2gray(I_f - LS_f);
D_nf = mat2gray(I_nf - LS_nf);


%% Plots

% figure
% imshow(I_f - I_nf), title('Delta intensity');
% 
% figure
% subplot(1,2,1), imshow(I_f), title('Intensity flash photo');
% subplot(1,2,2), imshow(I_nf), title('Intensity no flash photo');
% 
% figure
% subplot(1,2,1), imshow(C_f), title('Color flash photo');
% subplot(1,2,2), imshow(C_nf), title('Color no flash photo');
% 
% figure
% subplot(1,2,1), imshow(LS_f), title('Large scale flash photo');
% subplot(1,2,2), imshow(LS_nf), title('Large scale no flash photo');
% 
% figure
% subplot(1,2,1), imshow(D_f), title('Details flash photo');
% subplot(1,2,2), imshow(D_nf), title('Details no flash photo');
% 
% figure
% imshow(mat2gray(D_f + LS_nf)), title('Details flash + large scale no flash photo');

figure
imshow(C_f .* I_f .* mat2gray(D_f + LS_nf)), title('Result');