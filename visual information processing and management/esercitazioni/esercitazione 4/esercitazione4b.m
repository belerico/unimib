clear all;
close all;

boxImage = im2double(imread('images/stapleRemover.jpg'));
sceneImage = im2double(imread('images/clutteredDesk.jpg'));

%% Sliding window
% Image cropping

figure(1), clf
imshow(boxImage)
boxImage = imcrop(boxImage);

for scala=0.3:0.1:0.5
    boxImageR = imresize(boxImage, scala);
    Mappa = [];
    passo = 2;
    for rr=1:passo
        for cc=1:passo
            D = sceneImage(rr:, cc:) - boxImageR;
            D = mean(abs(D(:)));
            % Mappa = [Mappa ...]
        end
    end
end