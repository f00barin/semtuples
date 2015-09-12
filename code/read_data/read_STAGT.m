% Input: 
%        File with analyzed sentences in CONELL column format.
%        File with sentences annotated with semantic tuples 
%        Output: A matlab structure with one cell per sentence.

% fileAnNLP='Flickr8k.analyzed.aligned.txt';
% fileAnSenna = 'SRL_senna.txt'
% fileAnST='all_annotations.txt';
% N=3325 , number of ST annotations

function [labeledData,annos,captionName2annosIDs,annosID2captionName,Dictionaries1]=read_STAGT(fileAnNLP,fileAnST,Dictionaries)


[annos,captionName2annosIDs,annosID2captionName]=read_NLP_Pipeline_Output_withid_GT(fileAnNLP);
% [annos] = convertSRL(fileAnSenna,annos);
fid=fopen(fileAnST);
line=fgets(fid);
l=0;

actors2id=Dictionaries.actors2id;
id2actors=Dictionaries.id2actors;
locatives2id=Dictionaries.locatives2id;
id2locatives=Dictionaries.id2locatives;
predicates2id=Dictionaries.predicates2id;
id2predicates=Dictionaries.id2predicates;

nactors=Dictionaries.nactors;
nlocatives=Dictionaries.nlocatives;
npredicates=Dictionaries.npredicates;

for ii = 1:length(annos)
    hold{1} = annos(ii).capid;
    ids{ii} = hold{1};
end
while line ~= -1
    l = l+1;
    [arguments] = line2arguments(line);
    test = int2str(arguments.annosID);
    where = find(strcmp(test,ids));
    tree=annos(where);
    
    % PRED
    pred_lemma = [];
    beg=strfind(arguments.pred,'[')+1;
    ending=strfind(arguments.pred,']')-1;
    argumentString=arguments.pred(beg(1):ending(1));    
    if(isempty(argumentString))
        gT.pred_range={};
    elseif argumentString(2) == '-'
        gT.pred_range={};
    else
        argumentString(strfind(argumentString,','))=' ';
        [gT.pred_range] = parseArgument(argumentString);
        pred_lemma = unique(tree.lemmas(gT.pred_range),'stable');
    end
    % Dictionary
    if ~isempty(pred_lemma)  
        for ii=1:size(pred_lemma,1)
            pred = [];
            for jj=1:size(pred_lemma,2)
                pred = [pred  pred_lemma{ii,jj} '-'];
            end
            pred = pred(1:end-1);
            if(~predicates2id.isKey(pred))
                npredicates=npredicates+1;
                predicates2id(pred)=npredicates;
                id2predicates(npredicates)=pred;
            end
        end
    end
    
    % AGENTS
    agent_lemma = [];
    beg=strfind(arguments.agent,'[')+1;
    ending=strfind(arguments.agent,']')-1;
    argumentString=arguments.agent(beg(1):ending(1));
    if(isempty(argumentString))
        gT.agent_range={};
    else
        argumentString(strfind(argumentString,','))=' ';      
        [gT.agent_range] = parseArgument(argumentString);
        agent_lemma = unique(tree.lemmas(gT.agent_range),'stable');
    end
    % Dictionary
    if ~isempty(agent_lemma)  
        for ii=1:size(agent_lemma,1)
            pred = [];
            for jj=1:size(agent_lemma,2)
                pred = [pred  agent_lemma{ii,jj} '-'];
            end
            pred = pred(1:end-1);
            if(~actors2id.isKey(pred))
                nactors=nactors+1;
                actors2id(pred)=nactors;
                id2actors(nactors)=pred;
            end
        end
    end

    

    % PATIENTS
    patient_lemma = [];
    beg=strfind(arguments.pacient,'[')+1;
    ending=strfind(arguments.pacient,']')-1;
    argumentString=arguments.pacient(beg(1):ending(1));
    if(isempty(argumentString))
        gT.pacient_range={};
    else
        argumentString(strfind(argumentString,','))=' ';      
        [gT.pacient_range] = parseArgument(argumentString);
        patient_lemma = unique(tree.lemmas(gT.pacient_range),'stable');
    end
    % Dictionary
    if ~isempty(patient_lemma)  
        for ii=1:size(patient_lemma,1)
            pred = [];
            for jj=1:size(patient_lemma,2)
                pred = [pred  patient_lemma{ii,jj} '-'];
            end
            pred = pred(1:end-1);
            if(~actors2id.isKey(pred))
                nactors=nactors+1;
                actors2id(pred)=nactors;
                id2actors(nactors)=pred;
            end
        end
    end

    % LOCATIVE HEAD
    Loc_lemma = [];
    beg=strfind(arguments.loc_head,'[')+1;
    ending=strfind(arguments.loc_head,']')-1;
    argumentString=arguments.loc_head(beg(1):ending(1));
    if(isempty(argumentString))
        gT.locative_head_range={};
    else
        argumentString(strfind(argumentString,','))=' ';      
        [gT.locative_head_range] = parseArgument(argumentString);
        Loc_lemma = unique(tree.lemmas(gT.locative_head_range),'stable');
    end
    % Dictionary
    if ~isempty(Loc_lemma)  
        for ii=1:size(Loc_lemma,1)
            pred = [];
            for jj=1:size(Loc_lemma,2)
                pred = [pred  Loc_lemma{ii,jj} '-'];
            end
            pred = pred(1:end-1);
            if(~locatives2id.isKey(pred))
                nlocatives=nlocatives+1;
                locatives2id(pred)=nlocatives;
                id2locatives(nlocatives)=pred;
            end
        end
    end

    
    % LOCATIVE PREP
    beg=strfind(arguments.loc_prep,'[')+1;
    ending=strfind(arguments.loc_prep,']')-1;
    argumentString=arguments.loc_prep(beg(1):ending(1));
    if(isempty(argumentString))
        gT.locative_prep_range={};
    else
        argumentString(strfind(argumentString,','))=' ';      
        [gT.locative_prep_range] = parseArgument(argumentString);
    end
    
   
    labeledData(l).gT=gT;
    labeledData(l).arguments=arguments;
    labeledData(l).tree=tree;
    line=fgets(fid);
   % display(arguments);
end

Dictionaries1.actors2id=actors2id;
Dictionaries1.id2actors=id2actors;
Dictionaries1.locatives2id=locatives2id;
Dictionaries1.id2locatives=id2locatives;
Dictionaries1.predicates2id=predicates2id;
Dictionaries1.id2predicates=id2predicates;
Dictionaries1.nactors=nactors;
Dictionaries1.nlocatives=nlocatives;
Dictionaries1.npredicates=npredicates;
