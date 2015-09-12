% evaluate tuples
% this script evaluates manually and automatically generated tuples
%   load parsed information 
%   load hand annotations
%   train the model with current feature config
%   automatically extract tuples
%   put in matrix form then evaulate
clear all
addpath('extract_evaluate', 'read_data', 'train_models')
%% get parsed information
Dictionaries.actors2id=containers.Map('KeyType','char','ValueType','uint32');
Dictionaries.id2actors=containers.Map('KeyType','uint32','ValueType','char');
Dictionaries.locatives2id=containers.Map('KeyType','char','ValueType','uint32');
Dictionaries.id2locatives=containers.Map('KeyType','uint32','ValueType','char');
Dictionaries.predicates2id=containers.Map('KeyType','char','ValueType','uint32');
Dictionaries.id2predicates=containers.Map('KeyType','uint32','ValueType','char');

Dictionaries.nactors=0;
Dictionaries.nlocatives=0;
Dictionaries.npredicates=0;

% READ FILES
% read_STA_{} reads the analyzed files and pairs the information with the
% hand annotated tuples
fprintf('Reading data. This may take some time.. \n')
% Only 50 Clean images for evaluation:
[labeledData_mod1,annos_mod1,captionName2annosIDs_mod1,annosID2captionName_mod1,Dictionaries]=read_STA_othermods('text_files/cap_visen_NTR_m1_flickr_clean.withindex.txt.done','text_files/model1_gold.txt',Dictionaries);
[labeledData_mod2,annos_mod2,captionName2annosIDs_mod2,annosID2captionName_mod2,Dictionaries]=read_STA_othermods('text_files/cap_visen_NTR_m2_flickr_clean.withindex.txt.done','text_files/model2_gold.txt',Dictionaries);
[labeledData_GT,annos_GT,captionName2annosIDs_GT,annosID2captionName_GT,Dictionaries]=read_STAGT('text_files/Flickr8k.analyzed.aligned.processed.withindex.txt','text_files/clean_images_annotations.txt',Dictionaries);
% All hand annotated tuples for retraining the model:
[labeledData_GT_all,annos_GT_all,captionName2annosIDs_GT_all,annosID2captionName_GT_all,Dictionaries]=read_STAGT('text_files/Flickr8k.analyzed.aligned.processed.withindex.txt','text_files/all_annotations.txt',Dictionaries);
%% train model
% SECTION TEST SET OF 100 IMAGES FROM TRAINING SET
trainsize=separateTrainTestset(labeledData_GT_all);

% READ IMAGE TRAIN-TEST PARTITION OF TUPLE ANNOTATED DATA
fid=fopen('text_files/TrainImages_Tuples.txt');
for i=1:trainsize %211
    labeledImages_train{i}=strtrim(fgets(fid));
end
fid=fopen('text_files/TestImages_Tuples.txt');
for i=1:100
    labeledImages_test{i}=strtrim(fgets(fid));
end
trainImage2id=containers.Map(labeledImages_train,1:length(labeledImages_train));
testImage2id=containers.Map(labeledImages_test,1:length(labeledImages_test));
idtrain=0;
idtest=0;
for i=1:length(labeledData_GT_all)
    imFile=labeledData_GT_all(i).arguments.imageFile;
    data_point=labeledData_GT_all(i);
    if(trainImage2id.isKey(imFile)) %map contains given key
        idtrain=idtrain+1;
        labeledData_train(idtrain)=data_point;
    elseif(testImage2id.isKey(imFile))
        idtest=idtest+1;
        labeledData_test(idtest)=data_point;
    else
        'error'
        fprintf('Image key %s not found', imFile)
    end
end

% TRAIN THE MODEL USING 10-FOLD CROSS VALIDATION
fprintf('Training... \n')
[model_train,results,fscore]=train_argument_detectors_Xvalid(labeledData_train,[70 60 70 70],labeledData_test,7,[]); 

fprintf('Combining models\n')
model1.w_ag=[];
model1.w_pat=[];
model1.w_loc=[];
model1.w_none=[];
model1.th.ag=[];
model1.th.pat=[];
model1.th.loc=[];
model1.th.none=[];
for i=1:10
    model1.w_ag=[model1.w_ag model_train(i).w_agent];
    model1.w_pat=[model1.w_pat model_train(i).w_pacient];
    model1.w_loc=[model1.w_loc model_train(i).w_locative];
    model1.w_none=[model1.w_none model_train(i).w_NONE];
    model1.th.ag=[model1.th.ag model_train(i).th.agent];
    model1.th.pat=[model1.th.pat model_train(i).th.pacient];
    model1.th.loc=[model1.th.loc model_train(i).th.locative];
    model1.th.none=[model1.th.none model_train(i).th.NONE];
end
model.w_agent = mean(model1.w_ag,2);
model.w_pacient = mean(model1.w_pat,2);
model.w_locative = mean(model1.w_loc,2);
model.w_none = mean(model1.w_none,2);
model.th.agent = mean(model1.th.ag,2);
model.th.patent = mean(model1.th.pat,2);
model.th.locative = mean(model1.th.loc,2);
model.th.none = mean(model1.th.none,2);
model.fTemplates = model_train(1,1).fTemplates;

%% model made annotations
fprintf('Working on auto-extracted evaluation \n')
% READ IMAGE TRAIN-TEST PARTITION OF TUPLE ANNOTATED DATA
fid=fopen('text_files/clean_image_list.txt');
line = fgets(fid);
idim = 0;
while line ~= -1
    idim = idim+1;
    imageList{idim}=strtrim(line);
    line = fgets(fid);
end

Image2id=containers.Map(imageList,1:length(imageList));

% AGREGATE Handmade-Tuples FOR EACH model
% GT
ntuples_gt=zeros(length(imageList),1);    
for i=1:length(labeledData_GT)
    imid=Image2id(labeledData_GT(i).arguments.imageFile);
    ntuples_gt(imid)=ntuples_gt(imid)+1;
    GT(imid,ntuples_gt(imid)).arguments=labeledData_GT(i).arguments;
    GT(imid,ntuples_gt(imid)).tree=labeledData_GT(i).tree;
    GT(imid,ntuples_gt(imid)).gT=labeledData_GT(i).gT;
end
% Model 1
ntuples_mod1=zeros(length(imageList),1);    
for i=1:length(labeledData_mod1)
    imid=Image2id(labeledData_mod1(i).arguments.imageFile);
    ntuples_mod1(imid)=ntuples_mod1(imid)+1;
    MD1(imid,ntuples_mod1(imid)).arguments=labeledData_mod1(i).arguments;
    MD1(imid,ntuples_mod1(imid)).tree=labeledData_mod1(i).tree;
    MD1(imid,ntuples_mod1(imid)).gT=labeledData_mod1(i).gT;
end
% Model 2
ntuples_mod2=zeros(length(imageList),1);    
for i=1:length(labeledData_mod2)
    imid=Image2id(labeledData_mod2(i).arguments.imageFile);
    ntuples_mod2(imid)=ntuples_mod2(imid)+1;
    MD2(imid,ntuples_mod2(imid)).arguments=labeledData_mod2(i).arguments;
    MD2(imid,ntuples_mod2(imid)).tree=labeledData_mod2(i).tree;
    MD2(imid,ntuples_mod2(imid)).gT=labeledData_mod2(i).gT;
end

% PREDICT TUPLES FOR ALL TRAINING IMAGES USING THEIR CORRESPONDING CAPTIONS
fprintf('-extracting tuples \n')
cid=0;
captionList={};
for i=1:50
    cid=cid+1;
    cname=[imageList{i} '#0'];
    captionList{cid}=cname;
end
image2id=containers.Map(imageList,1:length(imageList));

addmods=0;
onlyverbs=0;
% extract tuples
[ST_mod1,captionList_mod1,Dictionaries_mod1]= extract_tuples_othermods([],imageList,image2id,model,annos_mod1,addmods,onlyverbs);
[ST_mod2,captionList_mod2,Dictionaries_mod2]= extract_tuples_othermods([],imageList,image2id,model,annos_mod2,addmods,onlyverbs);
close all
% MAKE tuples for predicted
fprintf('-preparing tuples in matrix format \n')
% Model 1
ntuples_p1=zeros(length(imageList),1);    
for i=1:length(ST_mod1)
    imid=image2id(ST_mod1{i}{1}.tree.caption_name(1:end-2));
    ntuples_p1(imid)=ntuples_p1(imid)+1;
    P1(imid,ntuples_p1(imid)).tuples=ST_mod1{i}{1}.tuples;
    P1(imid,ntuples_p1(imid)).tree=ST_mod1{i}{1}.tree;
end  
% Model 2
ntuples_p2=zeros(length(imageList),1);    
for i=1:length(ST_mod2)
    imid=image2id(ST_mod2{i}{1}.tree.caption_name(1:end-2));
    ntuples_p2(imid)=ntuples_p2(imid)+1;
    P2(imid,ntuples_p2(imid)).tuples=ST_mod2{i}{1}.tuples;
    P2(imid,ntuples_p2(imid)).tree=ST_mod2{i}{1}.tree;
end  

[Auto_M1] = toMatrixFormat(P1,Dictionaries,ntuples_p1);
[Auto_M2] = toMatrixFormat(P2,Dictionaries,ntuples_p2);
fprintf('Working with hand annotated tuples \n -preparing tuples in matrix format \n')
[GT1,GT_tuples] = GT_to_matrix(GT,Dictionaries);
[Hand_M1,M1_tuples] = GT_to_matrix(MD1,Dictionaries);
[Hand_M2,M2_tuples] = GT_to_matrix(MD2,Dictionaries);

%% evaluate
fprintf('Evaluating tuples')
% % evaluate
crfo = [1 2 3];
% hand models
% gold truth hand annotations vs. hand annotated for both models
[r_model1_hand] = evaluateSemanticTuples_matrixFormat(GT1,Hand_M1,crfo,Dictionaries);
[r_model2_hand] = evaluateSemanticTuples_matrixFormat(GT1,Hand_M2,crfo,Dictionaries);

% automatically generated models
% gold truth hand annotations vs. auto-generated for both models
[r_model1_auto] = evaluateSemanticTuples_matrixFormat(GT1,Auto_M1,crfo,Dictionaries);
[r_model2_auto] = evaluateSemanticTuples_matrixFormat(GT1,Auto_M2,crfo,Dictionaries);

% hand annotations for both models vs. auto-generated
[r_model1_h2a] = evaluateSemanticTuples_matrixFormat(Hand_M1,Auto_M1,crfo,Dictionaries);
[r_model2_h2a] = evaluateSemanticTuples_matrixFormat(Hand_M2,Auto_M2,crfo,Dictionaries);

