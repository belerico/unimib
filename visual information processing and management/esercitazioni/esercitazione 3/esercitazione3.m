im_orig = im2double(imread('images/colorTransfer/image1.png'));
im_target = im2double(imread('images/colorTransfer/image2.png'));

figure
subplot(1, 3, 1), imshow(im_orig), title('Originale');
subplot(1, 3, 2), imshow(im_target), title('Mood');

% conversione to ycbcr
im_orig = rgb2ycbcr(im_orig);
im_target = rgb2ycbcr(im_target);

size_orig = size(im_orig);
size_target = size(im_target);

% estrazione statistiche
im_orig = reshape(im_orig, [], 3);
medie_orig = mean(im_orig); % vettore 1x3

im_target = reshape(im_target, [], 3);
medie_target = mean(im_target); % vettore 1x3

std_orig = std(im_orig);
std_target = std(im_target);

%% Fare robe

im_orig(:, 2) = (((im_orig(:, 2) - medie_orig(2)) / std_orig(2)) * std_target(2)) + medie_target(2);
im_orig(:, 3) = (((im_orig(:, 3) - medie_orig(3)) / std_orig(3)) * std_target(3)) + medie_target(3);


%%

im_orig = reshape(im_orig, size_orig);
im_orig = ycbcr2rgb(im_orig);
subplot(1, 3, 3), imshow(im_orig), title('Mood transfered');


