function [fTemplates] = generateFeatureTemplates(annos)

feature2id=containers.Map('KeyType','char','ValueType','uint64');
id2feature=containers.Map('KeyType','uint64','ValueType','char');

% Lexical Features
id=0;
for i=1:length(annos)
    lemmas=annos(i).tree.lemmas;
    pos=annos(i).tree.pos; 
    verbs=strmatch('VB',pos);
    nouns=strmatch('NN',pos);
    
    for n=1:length(nouns)
        f=['lexical: ' lemmas{nouns(n)}];
        if(~feature2id.isKey(f))
            id=id+1;
            feature2id(f)=id;
            id2feature(id)=f;
        end
    end
    
    for v=1:length(verbs)
        for n=1:length(nouns)
            f=['lexical: ' lemmas{verbs(v)} ' ' lemmas{nouns(n)}];
            if(~feature2id.isKey(f))
                id=id+1;
                feature2id(f)=id;
                id2feature(id)=f;
            end
        end
    end
end

f='-pred-1';
if(~feature2id.isKey(f))
    id=id+1;
    feature2id(f)=id;
    id2feature(id)=f;
end
f='-NOpred-1';
if(~feature2id.isKey(f))
    id=id+1;
    feature2id(f)=id;
    id2feature(id)=f;
end

f='-NOSRL-1';
if(~feature2id.isKey(f))
    id=id+1;
    feature2id(f)=id;
    id2feature(id)=f;
end
% Semantic Role Labeler Features
for i=1:length(annos)
    preds=annos(i).tree.predicates_arg;
    
    for p=1:length(preds)
        pred=preds{p};
        for r=1:length(pred)
            role=strtrim(pred{r});
%             f=['semantic roles_1: ' '-pred- ' role];
%             if(~feature2id.isKey(f))
%                 id=id+1;
%                 feature2id(f)=id;
%                 id2feature(id)=f;
%             end
            f=['semantic roles_1: ' '-NOpred- ' role];
            if(~feature2id.isKey(f))
                id=id+1;
                feature2id(f)=id;
                id2feature(id)=f;
            end
            
            f=['role_1: ' role];
            if(~feature2id.isKey(f))
                id=id+1;
                feature2id(f)=id;
                id2feature(id)=f;
            end
            
        end
    end
end



% Syntactic features
ptypes{1}='asc';
ptypes{2}='asc-dec';

for k=1:length(ptypes)
    id=id+1;
    f=['path-type: ' ptypes{k}];
    feature2id(f)=id;
    id2feature(id)=f;
end
plengths{1}='<=1';
plengths{2}='<=2';
plengths{3}='<=3';
plengths{4}='<=4';
plengths{5}='>4';

for k=1:length(plengths)
    id=id+1;
    f=['path-l: ' plengths{k}];
    feature2id(f)=id;
    id2feature(id)=f;
end

for i=1:length(annos)
   % i
   % display(i);
    deps=annos(i).tree.dep_labels; 
    for d=1:length(deps)
        for t=1:length(ptypes)
            for l=1:length(plengths)
                f=['syn: ' deps{d} ' ' ptypes{t}  ' ' plengths{l}];
                if(~feature2id.isKey(f))
                    id=id+1;
                    feature2id(f)=id;
                    id2feature(id)=f;
                end
                f=['syn-inpath: ' deps{d} ' ' ptypes{t}  ' ' plengths{l}];
                if(~feature2id.isKey(f))
                    id=id+1;
                    feature2id(f)=id;
                    id2feature(id)=f;
                end
            end
        end
    end
end


for i=1:length(annos)
    deps=annos(i).tree.dep_labels; 
    for d=1:length(deps)
        f=['syn: ' deps{d}];
        if(~feature2id.isKey(f))
            id=id+1;
            feature2id(f)=id;
            id2feature(id)=f;
        end
        f=['syn-inpath: ' deps{d}];
        if(~feature2id.isKey(f))
            id=id+1;
            feature2id(f)=id;
            id2feature(id)=f;
        end
    end
end

fTemplates.feature2id=feature2id;
fTemplates.id2feature=id2feature;









