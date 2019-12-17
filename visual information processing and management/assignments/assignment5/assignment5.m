% This script need a folder data with
% - TestImages folder, containing the test images
% - NegativeExamples, containing non car images: i've also added negative images from image.orig class 1
% - PositiveExamples, containing car images

clc
clear
close all

%% preparazione
imageFileName = [];
bbs = {};
positiveInstances = table(imageFileName, bbs);
posPath = './data/PositiveExamples';
positive = dir(fullfile(posPath , 'pos-*.pgm'));

for i = 1 : numel(positive)
    file = fullfile('./data/PositiveExamples', positive(i).name);
    bb = [1 1 100 40];
    cell = {file, bb};
    positiveInstances = [positiveInstances ; cell];
   
end

negativeFolder = fullfile('./data/NegativeExamples');
negativeImages = imageDatastore(negativeFolder);

%% training
trainCascadeObjectDetector('carDetector.xml',...
    positiveInstances, negativeImages, 'FalseAlarmRate',0.1,...
    'NumCascadeStages',5);

%% detection

detector = vision.CascadeObjectDetector('carDetector.xml');
test_images = dir(fullfile('./data/TestImages' , 'test-*.jpg'));

for i=1:numel(test_images)
    path = test_images(i).name;
    fullPath = fullfile('./data/TestImages', path);
    img = imread(fullPath);
    bbox = detector(img);
    detectedImg = insertObjectAnnotation(img, 'rectangle', bbox, 'car');
    figure(i), clf, imshow(detectedImg, 'InitialMagnification', 500)
    pause(0.5)
end
