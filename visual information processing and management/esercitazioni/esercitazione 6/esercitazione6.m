disp('creazione griglia');
pointPositions=[];
featStep=5; % TBD
S=[40 100];
tic
for ii=featStep:featStep:S(1)-featStep
    for jj=featStep:featStep:S(2)-featStep
        pointPositions=[pointPositions; ii jj];
    end
end
toc

%% estrazione features
disp('estrazione features');
Nim4training=100; % TBD, fix nel caso di validation set
features=[];
labels=[];
tic
for class=0:1
    for nimage=0:Nim4training-1 % TBD, random??
        disp([num2str(class) '-' num2str(nimage)])
        if class==0
            im=im2double(imread(['./data/TrainImages/neg-' num2str(nimage) '.pgm']));
        else
            im=im2double(imread(['./data/TrainImages/pos-' num2str(nimage) '.pgm']));
        end
            
        im=imresize(im,S);
%         im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method','SURF');
        features=[features; imfeatures];
        labels=[labels; repmat(class,size(imfeatures,1),1) ...
                        repmat(nimage,size(imfeatures,1),1)];
    end
end
toc

%% creazione vocabolario
disp('kmeans')
K=100; % TBD
tic
[IDX,C]=kmeans(features,K);
toc

%% istogrammi training
disp('rappresentazione BOW training')
BOW_tr=[];
labels_tr=[];
tic
for class=0:1
    for nimage=1:Nim4training-1
        u=find(labels(:,1)==class & labels(:,2)==nimage);
        imfeaturesIDX=IDX(u);
        H=hist(imfeaturesIDX,1:K);
        H=H./sum(H);
        BOW_tr=[BOW_tr; H];
        labels_tr=[labels_tr; class];
    end
end
toc

%% classificatore
% TBD!!!
% input: BOW_tr e labels_tr

%% istogrammi test
disp('rappresentazione BOW test')
Nim4test=1;
step=1;% TBD

tic

for nimage=10%Nim4traini0ng:99
    BOW_te=[];
    labels_te=[];
    posizioni=[];
    im=im2double(imread(['./data/TestImages/test-' num2str(nimage) '.pgm']));
    for xx=1:step:size(im,1)-S(1)
        for yy=1:step:size(im,2)-S(2)
            finestra=im(xx:xx+S(1),yy:yy+S(2));
            
            [imfeatures,dontcare]=extractFeatures(finestra,pointPositions,'Method','SURF');
            
            %%%%
            D=pdist2(imfeatures,C);
            [dontcare,words]=min(D,[],2);
            %%%%
            H=hist(words,1:K);
            H=H./sum(H);
            BOW_te=[BOW_te; H];
            posizioni=[posizioni; xx yy];
        end
    end
    %%% classificazione di ognuna delle finestre
    predicted_class=[];
    distanze=[];
    for ii=1:size(BOW_te,1)
        H=BOW_te(ii,:);
        DH=pdist2(H,BOW_tr);
        u=find(DH==min(DH));
        predicted_class=[predicted_class; labels_tr(u(1))];
        distanze=[distanze; min(DH)];
    end
    %%% disegno
    upos=find(predicted_class==1);
    udis=find(distanze(upos)==min(distanze(upos)));
    finestra=posizioni(upos(udis),:);
    figure(1), clf
    if not(isempty(finestra))
        im=insertObjectAnnotation(im,'rectangle',[finestra(2) finestra(1) 100 40],'car');
    end
    imshow(im),drawnow
    
    
end
