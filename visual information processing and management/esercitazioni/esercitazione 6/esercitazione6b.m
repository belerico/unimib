clear all;
close all;

load('stopSignsAndCars.mat');
positiveInstances=stopSignsAndCars(:, 1:2);
imDir=fullfile(matlabroot,'toolbox','vision','visiondata','stopSignImages');
addpath(imDir);
negativeFolder=fullfile(matlabroot,'toolbox','vision','visiondata','nonStopSigns');
negativeImages=imageDatastore(negativeFolder);
trainCascadeObjectDetector('stopSign6dic19.xml',positiveInstances,negativeImages,'FalseAlarmRate',0.1,'NumCascadeStages',5);

%% Detection
detector=vision.CascadeObjectDetector('stopSign6dic19.xml');
img=imread('stopSignTest.jpg');
bbox=detector(img);
detectedImg=insertObjectAnnotation(img,'rectangle',bbox,'stop');

%% Print image
figure(1), clf
imshow(detectedImg);