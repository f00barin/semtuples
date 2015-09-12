% Input: File with analyzed sentences in CONELL column format.
% TO DO: Must describe analyzed file.
% Output: A matlab structure with one cell per sentence.

%fileAn='Flickr8k.analyzed.aligned.txt';

function [annos,captionName2annosIDs,annosID2captionName]=read_NLP_Pipeline_Output_withid_othermods(fileAn)

fid=fopen(fileAn);
sen_id=0;
line=fgets(fid);
line=strtrim(line);
while(line~=-1)
    if(length(line)>5)
        row=textscan(line,'%s');
        row=row{1};
        token_id=str2num(row{3});
        if(token_id==1)
            if(sen_id>0)
                annos(sen_id).capid=capid;
                annos(sen_id).caption_name=caption_name;
                annos(sen_id).tokens=[tokens '-'];
                annos(sen_id).lemmas=lemmas;
                annos(sen_id).pos=pos;
                annos(sen_id).dep=deps;
                annos(sen_id).dep_labels=dep_labels;
                annos(sen_id).wid=wids;
                annos(sen_id).predicates=predicates;
                annos(sen_id).predicates_arg=predicates_arg;
            end
            sen_id=sen_id+1;
            tokens=[];
            lemmas=[];
            pos=[];
            deps=[];
            dep_labels=[];
            wids=[];
            predicates=[];
            predicates_arg=[];
        end
        capid = row{1};
        caption_name=row{2};
        tokens=[tokens '-' row{4}];
        lemmas{token_id}=[row{5}];
        pos{token_id}=row{6};
        deps(token_id)=str2num(row{8});
        dep_labels{token_id}=row{9};
%         wids{token_id}=row{11};
        predicates{token_id}=row{10};
        for j=11:(length(row)-1)
            predicates_arg{j-10}{token_id}=row{j}(3:end);
        end
    end
    line=fgets(fid);
end
annos(sen_id).capid=capid;
annos(sen_id).caption_name=caption_name;
annos(sen_id).tokens=[tokens '-'];
annos(sen_id).lemmas=lemmas;
annos(sen_id).pos=pos;
annos(sen_id).dep=deps;
annos(sen_id).dep_labels=dep_labels;
annos(sen_id).wid=wids;
annos(sen_id).predicates=predicates;
annos(sen_id).predicates_arg=predicates_arg;

captionName2annosIDs=containers.Map('KeyType','char', 'ValueType','char');
annosID2captionName=containers.Map('KeyType','char', 'ValueType','char');
for i=1:length(annos)
    captionName=annos(i).caption_name;
    annosID=num2str(i);
    if(~captionName2annosIDs.isKey(captionName))
        captionName2annosIDs(captionName)=annosID;
        annosID2captionName(annosID)=captionName;
    else
        current_annos=captionName2annosIDs(captionName);
        annosID=[current_annos '_' annosID];
        captionName2annosIDs(captionName)=annosID;
    end
end









