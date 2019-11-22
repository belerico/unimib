clear all
clc
close all

% im=imread('underexposed.jpg');
% figure(1), imshow(im)
% 
% im=im2double(im);
% figure(2), imshow(im)
% 
% figure(3)
% for channel=1:3
%     subplot(1, 3, channel), imshow(im(:, :, channel))
% end

im=imread('underexposed.jpg');
im = im2double(im);

%% gamma correction 
% gamma = 0.5;
% im_c = im .^ gamma;
% figure(1), imshow(im_c), title(strcat('immagine corretta (gamma = ', string(gamma), ')'))

%% gamma correction adattiva

% RGB -> Ycbcr
Ycbcr = rgb2ycbcr(im);
Y = Ycbcr(:, :, 1);

% processing
F = fspecial('gaussian', 51, 21);
% Bilateral filtering
Y_fil = imbilatfilt(1 - Y);
% Y_fil = imfilter(1 - Y, F, 'same', 'replicate');
Y_cor = Y .^ (2 .^ ((0.5 - Y_fil) / 0.5));

% correzione contrasto
m = min(Y_cor(:));
M = max(Y_cor(:));
% hist stretching
Y_cor = (Y_cor - m) ./ (M - m);

% Ycbcr -> RGB
Ycbcr(:, :, 1) = Y_cor;
im_c = ycbcr2rgb(Ycbcr);

% correzione saturazione
HSV = rgb2hsv(im_c);
HSV(:, :, 2) = HSV(:, :, 2) * 1.5;
im_c = hsv2rgb(HSV);

figure(2), imshow(im_c)













