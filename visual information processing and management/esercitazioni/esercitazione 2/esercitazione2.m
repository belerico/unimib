clear all;
close all;

im1 = imread('images/orange.jpg');
im2 = imread('images/apple.jpg');

% figure
% subplot(1,2,1), imshow(im1)
% subplot(1,2,2), imshow(im2)

left_size = 140;
% mask creation
mask = [ones(1, left_size) linspace(1, 0, size(im1, 2) - 2 * left_size) zeros(1, left_size)];
mask = repmat(mask, 309, 1);

im1 = im2double(im1);
im2 = im2double(im2);
blend = mask .* im1 + (1 - mask) .* im2;

figure, imshow(blend);