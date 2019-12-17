clear all;
clc
close all;

net=alexnet;
% analyzeNetwork(net);
% net.Layers to visualize layers in the command window
sz=net.Layers(1).InputSize;

%% Cut layers

layersTransfer=net.Layers(1:end-3);
%layerTransfer=freezeWeights(layersTransfer);

%% Replace weights

numClass=10;
layers=[
    layersTransfer
    fullyConnectedLayer(numClass,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer
];

%% Data preparation

imds=imageDatastore('../esercitazione 5/image.orig/');
labels=[];
for ii=1:size(imds.Files,1)
   name=imds.Files{ii,1};
   [p,n,ex]=fileparts(name);
   class=floor(str2double(n)/100);
   labels=[labels; class];
end
labels=categorical(labels);
imds=imageDatastore('../esercitazione 5/image.orig/', 'labels', labels);

%% Split dataset

[imdsTrain,imdsTest]=splitEachLabel(imds,0.7,'randomized');

%% Data augmentation

pixelRange=[-5 5];
imageAugmenter=imageDataAugmenter( ...
    'RandXReflection', true, ...
    'RandXTranslation', pixelRange, ...
    'RandYTranslation', pixelRange ...
);
augImdsTrain=augmentedImageDatastore(sz(1:2),imdsTrain,'DataAugmentation',imageAugmenter);
augImdsTest=augmentedImageDatastore(sz(1:2),imdsTest);

%% Finetuning

option=trainingOptions(...
    'sgdm', ...
    'MiniBatchSize', 10, ...
    'MaxEpochs', 6, ...
    'InitialLearnRate', 1e-4, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augImdsTest, ...
    'ValidationFrequency', 3, ...
    'Verbose', false, ...
    'Plots', 'training-progress' ...
);

%% Training

netTransfer=trainNetwork(augImdsTrain,layers,option);

%% Test

[lab_pred_te,scores]=classify(netTransfer,augImdsTest);

%% Performance

acc=numel(find(lab_pred_te==imdsTest.Labels))/numel(imdsTest.Labels)



