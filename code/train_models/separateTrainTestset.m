
function trainr = separateTrainTestset(labeledData)

list=[];
[r,N] = size(labeledData);
for i=1:N
    list = [list; cellstr(labeledData(1,i).arguments.imageFile)];
end

% remove all duplicates
listND=unique(list);

%section off 100 for test
fid=fopen('text_files/TestImages_Tuples.txt');
for i=1:100
    labeledImages_test{i}=strtrim(fgets(fid));
end
testImage2id=containers.Map(labeledImages_test,1:length(labeledImages_test));
idtrain=0;
idtest=0;
for i=1:length(listND)
    %imFile=labeledData(i).arguments.imageFile;
    %data_point=labeledData(i);
    if(~testImage2id.isKey(listND(i,1))) %map contains given key
        idtrain=idtrain+1;
        TrainIM(idtrain,1)=listND(i,1);
    else
        idtest=idtest+1;
        TestIM(idtest,1)=listND(i,1);
    end
end

  if idtest ~= 100
    'error: Didnt detect enough test images'
    pause
end
% write train images
fileID = fopen('text_files/TrainImages_Tuples.txt','w');
formatSpec = '%s \n';
[trainr,trainc]=size(TrainIM);
for row = 1:trainr
    fprintf(fileID,formatSpec,TrainIM{row,:});
end

