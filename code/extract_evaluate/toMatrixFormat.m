function [TM] = toMatrixFormat(P,Dictionaries,ntuples)

TM=cell(size(P,1),1);
for i=1:size(P,1)
  %  display(['Image: ' num2str(i)]);
    id=0;

    for j=1:ntuples(i)
        for k=1:length(P(i,j).tuples)
            locatives=P(i,j).tuples{k}.locatives;
            predicates=P(i,j).tuples{k}.pred;
            actors=P(i,j).tuples{k}.actors;
            if(~iscell(predicates))
                clear predicates;
                predicates{1}=P(i,j).tuples{k}.pred;
            end
            if(~iscell(locatives))
                clear locatives;
                locatives{1}=P(i,j).tuples{k}.locatives;
            end
            if(~iscell(actors))
                clear actors;
                actors{1}=P(i,j).tuples{k}.actors;
            end
            
            for kk=1:length(locatives)
                locid=Dictionaries.nlocatives + 1; % default unknown
                if(Dictionaries.locatives2id.isKey(locatives{kk}))
                    locid=Dictionaries.locatives2id(locatives{kk});
                end                
                for kkk=1:length(predicates)
                    predid=Dictionaries.npredicates + 1; 
                    if(Dictionaries.predicates2id.isKey(predicates{kkk}))
                        predid=Dictionaries.predicates2id(predicates{kkk});
                    end                   
                    for kkkk=1:length(actors)
                        actorsid=Dictionaries.nactors +1 ; 
                        if(Dictionaries.actors2id.isKey(actors{kkkk}))
                            actorsid=Dictionaries.actors2id(actors{kkkk});
                        end 
                        id=id+1;
                        TM{i}(id,:)=[locid predid actorsid];
                    end
                end
            end
        end
    end
end
