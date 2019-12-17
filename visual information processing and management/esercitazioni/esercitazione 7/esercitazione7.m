net=alexnet;
% analyzeNetwork(net);
% net.Layers to visualize layers in the command window
sz=net.Layers(1).InputSize;
activation_layer='fc7';

%% Features extarction

indir='../esercitazione 5/image.orig/';
ims=dir([indir '*.jpg']);
feat_tr=[];
labels_tr=[];
Nim4train=70;
tic
for class=0:9
   for nimage=0:Nim4train-1
      im=double(imread([indir num2str(100*class+nimage) '.jpg']));
      im=imresize(im,sz(1:2));
      feat_tmp=activations(net,im,activation_layer,'OutputAs','rows');
      feat_tr=[feat_tr; feat_tmp];
   end
   labels_tr=[labels_tr; class*ones(Nim4train,1)];
end
toc

%% Test set features extraction

feat_te=[];
labels_te=[];

tic
for class=0:9
   for nimage=Nim4train:99
      im=double(imread([indir num2str(100*class+nimage) '.jpg']));
      im=imresize(im,sz(1:2));
      feat_tmp=activations(net,im,activation_layer,'OutputAs','rows');
      feat_te=[feat_te; feat_tmp];
   end
   labels_te=[labels_te; class*ones(100-Nim4train,1)];
end
toc

%% Features normalization

% feat_tr=feat_tr./sqrt(sum(feat_tr.^2,2));
% feat_te=feat_te./sqrt(sum(feat_te.^2,2));

%% 1-NN classification

D=pdist2(feat_te,feat_tr);
[~, idx_pred_te]=min(D,[],2);
lab_pred_te=labels_tr(idx_pred_te);
acc=numel(find(lab_pred_te==labels_te))/numel(labels_te)



