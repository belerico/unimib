clear all;
close all;

boxImage = im2double(imread('images/stapleRemover.jpg'));
sceneImage = im2double(imread('images/clutteredDesk.jpg'));

%% Interesting point extraction and visualization

boxPoints = detectSURFFeatures(boxImage);
scenePoints = detectSURFFeatures(sceneImage);

figure(1), clf
imshow(boxImage), hold on
plot(selectStrongest(boxPoints, 100)), hold off

figure(2), clf
imshow(sceneImage), hold on
plot(selectStrongest(scenePoints, 100)), hold off

%% Interesting points descriptors

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

%% Similarity between features

boxPairs = matchFeatures(boxFeatures, sceneFeatures);
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);

%% Plot matched points based on features

figure(3), clf
showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, matchedScenePoints, 'montage')

%% Ransac trasnsformation

[tform, inlierBoxPoints, inlierScenePoints] = estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');
figure(4), clf
showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, inlierScenePoints, 'montage')

%% Detection with a coarse bounding box

boxPoly = [1 1; size(boxImage, 2), 1; size(boxImage, 2), size(boxImage, 1); 1 size(boxImage, 1); 1 1];
newBoxPoly = transformPointsForward(tform, boxPoly);
figure(5), clf
imshow(sceneImage), hold on
line(newBoxPoly(:, 1), newBoxPoly(:, 2), 'Color', 'y')
hold off

%% Hint assignment
% Get n points manually

figure(6), clf
imshow(sceneImage)
[x, y] = ginput(3)

