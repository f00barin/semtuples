  % Input:
%       List Caption Names or List of ImageNames.
%       File with analyzed sentences in CONELL column format.
%       Argument Classifiers 
% Output:
%       List of tuples associated to each caption

%fileAn='Flickr8k.analyzed.aligned.txt';
%captionList={};
%fileImgNames='Flickr_8k.trainImages.txt';
%fileImgNames='Flickr_8k.testImages.txt';


function [ST,captionList,Dictionaries]= extract_tuples_othermods(fileAn,captionList,captionName2annosIDs,model,annos,ADDMODS,ONLYVERBS)

w_agent=model.w_agent;
w_pacient=model.w_pacient;
w_locative=model.w_locative;
w_none = model.w_none;
th=model.th;
fTemplates=model.fTemplates;

if(isempty(annos))
    [annos,captionName2annosIDs]=read_NLP_Pipeline_Output_withid_othermods(fileAn);
end

maxloopsdone = [];

for i=1:length(captionList)
    clear tuples;
    clear tuple;
    clear A;
    clear a;
    
    annosIDs=captionName2annosIDs(captionList{i});
    [id rest]=strtok(annosIDs,'_');
    n=1;
    A{n}=annos(id);
    while(~isempty(rest))
        n=n+1;
        [id rest]=strtok(rest,'_');
        A{n}=annos(id);
    end
    
    for s=1:length(A)
        
        a=A{s};
        
        tuple.locatives{1}='null';
        tuple.actors{1}='null';  
        tuple.pred='null';     
        tuples{1}=tuple;
             
        preds=strmatch('VB',a.pos);
        
        if(~ONLYVERBS)
            if(isempty(preds))
                preds=strmatch('NN',a.pos);
            end
            if(isempty(preds))
                preds=strmatch('JJ',a.pos);
            end
            if(isempty(preds))
                preds=[1:length(a.pos)];
            end
        end
        
        cand=strmatch('NN',a.pos);
        if(isempty(cand))
            cand=strmatch('JJ',a.pos);
        end
        if(isempty(cand))
            cand=[1:length(a.pos)];
        end
    for p=1:length(preds)
        pred=preds(p);
        [paths,types] = genPaths_v2(a, pred);
        scores=zeros(length(cand),3);
        
        for n=1:length(cand)
            [fvector] = path2fvector(paths{cand(n)},types(cand(n)),a,fTemplates);
            scores(n,1)=w_agent'*fvector;
            scores(n,2)=w_pacient'*fvector;
            scores(n,3)=w_locative'*fvector;
            scores(n,4)=w_none'*fvector;
        end    
        % Arguments
        actors = {};
        agents = {};
        pacients = {};
        locatives = {};
        none = {};
        thagent = th.agent;
        thpacient = th.patent;
        thlocative = th.locative;
        thnone = th.none;
        loopsdone = 0;
        while isempty(actors) || isempty(locatives)
            agents=cand(find(scores(:,1)>=thagent));
            pacients=cand(find(scores(:,2)>=thpacient));
            locatives=cand(find(scores(:,3)>=thlocative));
            none=cand(find(scores(:,4)>=thnone));
            actors=union(agents,pacients);
            %locatives=setdiff(locatives,actors);
            if isempty(agents)
                thagent = thagent - 0.1;
            end
            if isempty(pacients)
                thpacient = thpacient - 0.1;
            end
            if isempty(locatives)
                thlocative = thlocative - 0.1;
            end
            loopsdone = loopsdone +1;
        end
        maxloopsdone=[maxloopsdone loopsdone];
        
        % Modifiers
        for k=1:length(actors)
            [paths,types] = genPaths_v2(a, actors(k));
            mods_actors{k}=[];
            for kk=1:length(paths)
                path=paths{kk};
                adj=strmatch('JJ',a.pos(path));
                adj=path(adj);
                if(~isempty(adj) && length(path)<4)
                    mods_actors{k}=[mods_actors{k} adj];
                end
            end
        end
        for k=1:length(locatives)
            [paths,types] = genPaths_v2(a, locatives(k));
            mods_locatives{k}=[];
            for kk=1:length(paths)
                path=paths{kk};
                adj=strmatch('JJ',a.pos(path));
                adj=path(adj);
                if(~isempty(adj) && length(path)<4)
                    mods_locatives{k}=[mods_locatives{k} adj];
                end
           end
       end
                
       tuple.pred=a.lemmas(pred);
       for j=1:length(actors)
           actorj=a.lemmas{actors(j)};
           if(ADDMODS)
                mods=unique(mods_actors{j});
                for jj=1:length(mods)
                    actorj=[actorj ' ' a.lemmas{mods(jj)}];
                end
           end
           tuple.actors{j}=actorj;
       end
       for j=1:length(locatives)
           locativej=a.lemmas{locatives(j)};
           if(ADDMODS)
                mods=unique(mods_locatives{j});
                for jj=1:length(mods)
                    locativej=[locativej ' ' a.lemmas{mods(jj)}];
                end
           end
           tuple.locatives{j}=locativej; 
        end
        tuples{p}.locatives=unique(tuple.locatives);
        tuples{p}.actors=unique(tuple.actors);
        tuples{p}.pred=unique(tuple.pred);
    end
        
        ST{i}{s}.tuples=tuples;
        ST{i}{s}.tree=a;
    end
end

actors2id=containers.Map('KeyType','char','ValueType','uint32');
id2actors=containers.Map('KeyType','uint32','ValueType','char');
locatives2id=containers.Map('KeyType','char','ValueType','uint32');
id2locatives=containers.Map('KeyType','uint32','ValueType','char');
predicates2id=containers.Map('KeyType','char','ValueType','uint32');
id2predicates=containers.Map('KeyType','uint32','ValueType','char');
modifiers2id=containers.Map('KeyType','char','ValueType','uint32');
id2modifiers=containers.Map('KeyType','uint32','ValueType','char');

nactors=0;
nlocatives=0;
npredicates=0;
nmodifiers=0;

figure;hist(maxloopsdone)


for i=1:length(ST)
    for ii=1:length(ST{i})
        tuples=ST{i}{ii}.tuples;
        for p=1:length(tuples)
            tuple=tuples{p};
            if(iscell(tuple.pred))
                pred=tuple.pred{1};
            else
                pred=tuple.pred;
            end
            pred=strtrim(pred);
            if(~predicates2id.isKey(pred))
                npredicates=npredicates+1;
                predicates2id(pred)=npredicates;
                id2predicates(npredicates)=pred;
            end
        
            locatives=tuple.locatives;
            for j=1:length(locatives)
                loc=textscan(locatives{j},'%s');
                loc=loc{1};
                if(~locatives2id.isKey(strtrim(loc{1})))
                    nlocatives=nlocatives+1;
                    locatives2id(strtrim(loc{1}))=nlocatives;
                    id2locatives(nlocatives)=strtrim(loc{1});
                end
                for k=2:length(loc)
                    mod=strtrim(loc{k});
                    if(~modifiers2id.isKey(mod))
                        nmodifiers=nmodifiers+1;
                        modifiers2id(mod)=nmodifiers;
                        id2modifiers(nmodifiers)=mod;
                    end
                end
            end
        
            actors=tuple.actors;
            for j=1:length(actors)
                actor=textscan(actors{j},'%s');
                actor=actor{1};
                if(~actors2id.isKey(strtrim(actor{1})))
                    nactors=nactors+1;
                    actors2id(strtrim(actor{1}))=nactors;
                    id2actors(nactors)=strtrim(actor{1});
                end
                for k=2:length(actor)
                    mod=strtrim(actor{k});
                    if(~modifiers2id.isKey(mod))
                        nmodifiers=nmodifiers+1;
                        modifiers2id(mod)=nmodifiers;
                        id2modifiers(nmodifiers)=mod;
                    end
                end
            end
        end
    end
end
Dictionaries.actors2id=actors2id;
Dictionaries.id2actors=id2actors;
Dictionaries.locatives2id=locatives2id;
Dictionaries.id2locatives=id2locatives;
Dictionaries.predicates2id=predicates2id;
Dictionaries.id2predicates=id2predicates;
Dictionaries.modifiers2id=modifiers2id;
Dictionaries.id2modifiers=id2modifiers;
Dictionaries.nactors=nactors;
Dictionaries.nlocatives=nlocatives;
Dictionaries.npredicates=npredicates;
Dictionaries.nmodifiers=nmodifiers;


















