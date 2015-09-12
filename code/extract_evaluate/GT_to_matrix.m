function [TM,P,tuple2ima]=GT_to_matrix(GT, Dictionaries)

top=1;
ima2tuple = containers.Map();
tuple2ima = containers.Map();

id=1;
for i=1:size(GT,1)
    for j=1:size(GT,2)
        anno=GT(i,j);
        if ~isempty(anno.arguments)
            % tuple.pred = regexp(anno.arguments.pred,'''([a-z\-]*)''','tokens');
            % agent = regexp(anno.arguments.agent,'''([a-z\-]*)''','tokens');
            % patient = regexp(anno.arguments.pacient,'''([a-z\-]*)''','tokens');
            % tuple.actors = [agent, patient];
            % tuple.locatives = regexp(anno.arguments.loc_head,'''([a-z\-]*)''','tokens');

            % if isempty(tuple.pred)
            %     tuple.pred = {'null'};
            % else
            %     tuple.pred = tuple.pred{1};
            % end
            % if isempty(tuple.locatives)
            %     tuple.locatives = {'null'};
            % else
            %     tuple.locatives = tuple.locatives{1};
            % end
            % if isempty(tuple.actors)
            %     tuple.actors = {'null'};
            % else
            %     tuple.actors = tuple.actors{1};
            % end
            
            %% predicate
            if ~isempty(anno.gT.pred_range)
                tuple.pred = {};
                for k=1:size(anno.gT.pred_range,1)
                    thispred='';
                    for t=anno.gT.pred_range(k,1):anno.gT.pred_range(k,2)
                        thispred=[thispred '-' anno.tree.lemmas{t}];
                    end
                    thispred = thispred(2:end); %remove leading -
                    tuple.pred = [tuple.pred thispred];
                end
            end
            if ~isempty(anno.gT.locative_head_range)
                tuple.locatives = {};
                for k=1:size(anno.gT.locative_head_range,1)
                    thisloc='';
                    for t=anno.gT.locative_head_range(k,1):anno.gT.locative_head_range(k,2)
                        thisloc=[thisloc '-' anno.tree.lemmas{t}];
                    end
                    thisloc = thisloc(2:end); %remove leading -
                    tuple.locatives = [tuple.locatives thisloc];
                end
            else
                tuple.locatives={'null'};
            end

            tuple.actors = {};            
            if ~isempty(anno.gT.agent_range)
                for k=1:size(anno.gT.agent_range,1)
                    thisactor='';
                    for t=anno.gT.agent_range(k,1):anno.gT.agent_range(k,2)
                        thisactor=[thisactor '-' anno.tree.lemmas{t}];
                    end
                    thisactor = thisactor(2:end); %remove leading -
                    tuple.actors = [tuple.actors thisactor];
                end
            end
            if ~isempty(anno.gT.pacient_range)
                for k=1:size(anno.gT.pacient_range,1)
                    thisactor='';
                    for t=anno.gT.pacient_range(k,1):anno.gT.pacient_range(k,2)
                        thisactor=[thisactor '-' anno.tree.lemmas{t}];
                    end
                    thisactor = thisactor(2:end); %remove leading -
                    tuple.actors = [tuple.actors thisactor];
                end
            end
            if isempty(anno.gT.agent_range) && ...
                    isempty(anno.gT.pacient_range)
                tuple.actors = {'null'};
            end

            if ima2tuple.isKey(anno.arguments.imageFile)
                id = ima2tuple(anno.arguments.imageFile);
                P(id).tuples = horzcat(P(id).tuples, {tuple});
            else
                ima2tuple(anno.arguments.imageFile)=top;
                tuple2ima(num2str(top))=anno.arguments.imageFile;
                id = top;
                top=top+1;
                P(id).tuples = {tuple};
                P(id).imaname = anno.arguments.imageFile;
            end

            %P(id).capnum = j;
            %id=id+1;
        end
    end
end

TM=toMatrixFormat(P',Dictionaries,ones(length(P)));
if ~Dictionaries.locatives2id.isKey('null')
    Dictionaries.locatives2id('null')=Dictionaries.nlocatives+1;
end
locativeNull=Dictionaries.locatives2id('null');
if ~Dictionaries.predicates2id.isKey('null')
    Dictionaries.predicates2id('null')=Dictionaries.npredicates+1;
end
predicateNull=Dictionaries.predicates2id('null');
if ~Dictionaries.actors2id.isKey('null')
    Dictionaries.actors2id('null')=Dictionaries.nactors+1;
end
actorNull=Dictionaries.actors2id('null');
TM_filtered=cell(length(TM),1);
for i=1:length(TM)
    j=0;
    gold=TM{i};
    for k=1:size(gold,1)
        if(gold(k,1)~=locativeNull && gold(k,2)~=predicateNull && ...
           gold(k,3)~=actorNull)
            j=j+1;
            TM_filtered{i}(j,:)=gold(k,:);
        end
    end
    TM_filtered{i}=unique(TM_filtered{i},'rows');
end                      

