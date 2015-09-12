function [r] = evaluateSemanticTuples_matrixFormat(GTin,P,crfo,Dictionaries)

if size(GTin,2)>1
    GT=cell(size(GTin,1),1);
    for i=1:size(GTin,1)
        GT{i}=[GTin{i,1};GTin{i,2};GTin{i,3};GTin{i,4};GTin{i,5}];
    end
else
    GT=GTin;
end

nImages=size(GT,1);
r.precision.unigrams.predicates=zeros(nImages,1);
r.precision.unigrams.actors=zeros(nImages,1);
r.precision.unigrams.locatives=zeros(nImages,1);
r.precision.bigrams.predicates_actors=zeros(nImages,1);
r.precision.bigrams.predicates_locatives=zeros(nImages,1);
r.precision.bigrams.actors_locatives=zeros(nImages,1);
r.precision.bigrams.predicates_actors_locatives=zeros(nImages,1);
r.recall.unigrams.predicates=zeros(nImages,1);
r.recall.unigrams.actors=zeros(nImages,1);
r.recall.unigrams.locatives=zeros(nImages,1);
r.recall.bigrams.predicates_actors=zeros(nImages,1);
r.recall.bigrams.predicates_locatives=zeros(nImages,1);
r.recall.bigrams.actors_locatives=zeros(nImages,1);
r.recall.bigrams.predicates_actors_locatives=zeros(nImages,1);
r.f1.unigrams.predicates=zeros(nImages,1);
r.f1.unigrams.actors=zeros(nImages,1);
r.f1.unigrams.locatives=zeros(nImages,1);
r.f1.bigrams.predicates_actors=zeros(nImages,1);
r.f1.bigrams.predicates_locatives=zeros(nImages,1);
r.f1.bigrams.actors_locatives=zeros(nImages,1);
r.f1.trigrams.predicates_actors_locatives=zeros(nImages,1);


nonZero=zeros(length(GT),1);
top=0;
for i=1:length(GT)
   % i
    gold=GT{i};
    predicted=P{i};
    
    if(~isempty(gold))
        gold=gold(:,crfo); %order properly
        top=top+1;
        nonZero(top)=i;
        % UNIGRAMS
        locatives_gold=unique(gold(:,1));
        locatives_gold(find(locatives_gold==(Dictionaries.nlocatives+1)))=[];
        locatives_pred=unique(predicted(:,1));
        locatives_pred(find(locatives_pred==(Dictionaries.nlocatives+1)))=[];
        n_predictions=length(locatives_pred);
        n_gold=length(locatives_gold);
        n_correct=length(intersect(locatives_pred,locatives_gold));
        [r.precision.unigrams.locatives(i),r.recall.unigrams.locatives(i),r.f1.unigrams.locatives(i)] = getMeasures(n_predictions,n_gold,n_correct);
    
        predicates_gold=unique(gold(:,2));
        predicates_gold(find(predicates_gold==(Dictionaries.npredicates+1)))=[];
        predicates_pred=unique(predicted(:,2));
        predicates_pred(find(predicates_pred==(Dictionaries.npredicates+1)))=[];
        n_predictions=length(predicates_pred);
        n_gold=length(predicates_gold);
        n_correct=length(intersect(predicates_pred,predicates_gold));
        [r.precision.unigrams.predicates(i),r.recall.unigrams.predicates(i),r.f1.unigrams.predicates(i)] = getMeasures(n_predictions,n_gold,n_correct);
    
        actors_gold=unique(gold(:,3));
        actors_gold(find(actors_gold==(Dictionaries.nactors+1)))=[];
        actors_pred=unique(predicted(:,3));
        actors_pred(find(actors_pred==(Dictionaries.nactors+1)))=[];
        n_predictions=length(actors_pred);
        n_gold=length(actors_gold);
        n_correct=length(intersect(actors_pred,actors_gold));
        [r.precision.unigrams.actors(i),r.recall.unigrams.actors(i),r.f1.unigrams.actors(i)] = getMeasures(n_predictions,n_gold,n_correct);
    
        % BIGRAMS  
        locPred_gold=unique(gold(:,1:2),'rows');
        locPred_pred=unique(predicted(:,1:2),'rows');
        id=[];
        for ii = 1:size(locPred_gold,1)
            interest = locPred_gold(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.npredicates)
                id = [id,ii];
            end
        end
        locPred_gold(id,:)=[];
        
        id=[];
        for ii = 1:size(locPred_pred,1)
            interest = locPred_pred(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.npredicates)
                id = [id,ii];
            end
        end
        locPred_pred(id,:)=[];
        
        n_predictions=length(locPred_pred);
        n_gold=length(locPred_gold);
        n_correct=length(intersect(locPred_pred,locPred_gold,'rows'));
        [r.precision.bigrams.predicates_locatives(i),r.recall.bigrams.predicates_locatives(i),r.f1.bigrams.predicates_locatives(i)] = getMeasures(n_predictions,n_gold,n_correct);
    
        locActor_gold=unique(gold(:,[1,3]),'rows');
        locActor_pred=unique(predicted(:,[1,3]),'rows');
        id=[];
        for ii = 1:size(locActor_gold,1)
            interest = locActor_gold(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        locActor_gold(id,:)=[];
        
        id=[];
        for ii = 1:size(locActor_pred,1)
            interest = locActor_pred(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        locActor_pred(id,:)=[];
        
        n_predictions=length(locActor_pred);
        n_gold=length(locActor_gold);
        n_correct=length(intersect(locActor_pred,locActor_gold,'rows'));
        [r.precision.bigrams.actors_locatives(i),r.recall.bigrams.actors_locatives(i),r.f1.bigrams.actors_locatives(i)] = getMeasures(n_predictions,n_gold,n_correct);

        predActor_gold=unique(gold(:,2:3),'rows');
        predActor_pred=unique(predicted(:,2:3),'rows');
        id=[];
        for ii = 1:size(predActor_gold,1)
            interest = predActor_gold(ii,:);
            if (interest(1) == Dictionaries.npredicates) || (interest(2) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        predActor_gold(id,:)=[];
        
        id=[];
        for ii = 1:size(predActor_pred,1)
            interest = predActor_pred(ii,:);
            if (interest(1) == Dictionaries.npredicates) || (interest(2) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        predActor_pred(id,:)=[];
        
        n_predictions=length(predActor_pred);
        n_gold=length(predActor_gold);
        n_correct=length(intersect(predActor_pred,predActor_gold,'rows'));
        [r.precision.bigrams.predicates_actors(i),r.recall.bigrams.predicates_actors(i),r.f1.bigrams.predicates_actors(i)] = getMeasures(n_predictions,n_gold,n_correct);

        % TRIGRAMS
        predActorLoc_gold=unique(gold(:,1:3),'rows');
        predActorLoc_pred=unique(predicted(:,1:3),'rows');
        id = [];
        for ii = 1:size(predActorLoc_gold,1)
            interest = predActorLoc_gold(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.npredicates || interest(3) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        predActorLoc_gold(id,:)=[];
        
        id = [];
        for ii = 1:size(predActorLoc_pred,1)
            interest = predActorLoc_pred(ii,:);
            if (interest(1) == Dictionaries.nlocatives) || (interest(2) == Dictionaries.npredicates || interest(3) == Dictionaries.nactors)
                id = [id,ii];
            end
        end
        predActorLoc_pred(id,:)=[];
        
        n_predictions=length(predActorLoc_pred);
        n_gold=length(predActorLoc_gold);
        n_correct=length(intersect(predActorLoc_pred,predActorLoc_gold,'rows'));
        [r.precision.trigrams.predicates_actors_locatives(i),r.recall.trigrams.predicates_actors_locatives(i),r.f1.trigrams.predicates_actors_locatives(i)] = getMeasures(n_predictions,n_gold,n_correct);
 
    else
        r.precision.unigrams.locatives(i)=1;
        r.recall.unigrams.locatives(i)=1;
        r.f1.unigrams.locatives(i) = 1;
        r.precision.unigrams.predicates(i)=1;
        r.recall.unigrams.predicates(i)=1;
        r.f1.unigrams.predicates(i) = 1;
        r.precision.unigrams.actors(i) = 1;
        r.recall.unigrams.actors(i)=1;
        r.f1.unigrams.actors(i) = 1;        
        r.precision.bigrams.predicates_locatives(i)=1;
        r.recall.bigrams.predicates_locatives(i)=1;
        r.f1.bigrams.predicates_locatives(i)=1;
        r.precision.bigrams.actors_locatives(i)=1;
        r.recall.bigrams.actors_locatives(i)=1;
        r.f1.bigrams.actors_locatives(i) = 1;
        r.precision.bigrams.predicates_actors(i)=1;
        r.recall.bigrams.predicates_actors(i)=1;
        r.f1.bigrams.predicates_actors(i) = 1;
        r.precision.trigrams.predicates_actors_locatives(i)=1;
        r.recall.trigrams.predicates_actors_locatives(i)=1;
        r.f1.trigrams.predicates_actors_locatives(i) = 1;
    end
end
nonZero=nonZero(1:top);
r.avgF1.unigrams.actors=mean(r.f1.unigrams.actors(nonZero));
r.avgF1.unigrams.predicates=mean(r.f1.unigrams.predicates(nonZero));
r.avgF1.unigrams.locatives=mean(r.f1.unigrams.locatives(nonZero));
r.avgPrec.unigrams.actors=mean(r.precision.unigrams.actors(nonZero));
r.avgPrec.unigrams.predicates=mean(r.precision.unigrams.predicates(nonZero));
r.avgPrec.unigrams.locatives=mean(r.precision.unigrams.locatives(nonZero));
r.avgRecall.unigrams.actors=mean(r.recall.unigrams.actors(nonZero));
r.avgRecall.unigrams.predicates=mean(r.recall.unigrams.predicates(nonZero));
r.avgRecall.unigrams.locatives=mean(r.recall.unigrams.locatives(nonZero));

r.avgF1.bigrams.predictes_actors=mean(r.f1.bigrams.predicates_actors(nonZero));
r.avgF1.bigrams.predicates_locatives=mean(r.f1.bigrams.predicates_locatives(nonZero));
r.avgF1.bigrams.actors_locatives=mean(r.f1.bigrams.actors_locatives(nonZero));
r.avgPrec.bigrams.predictes_actors=mean(r.precision.bigrams.predicates_actors(nonZero));
r.avgPrec.bigrams.predicates_locatives=mean(r.precision.bigrams.predicates_locatives(nonZero));
r.avgPrec.bigrams.actors_locatives=mean(r.precision.bigrams.actors_locatives(nonZero));
r.avgRecall.bigrams.predictes_actors=mean(r.recall.bigrams.predicates_actors(nonZero));
r.avgRecall.bigrams.predicates_locatives=mean(r.recall.bigrams.predicates_locatives(nonZero));
r.avgRecall.bigrams.actors_locatives=mean(r.recall.bigrams.actors_locatives(nonZero));

r.avgF1.trigrams.predictes_actors_locatives=mean(r.f1.trigrams.predicates_actors_locatives(nonZero));
r.avgPrec.trigrams.predictes_actors_locatives=mean(r.precision.trigrams.predicates_actors_locatives(nonZero));
r.avgRecall.trigrams.predictes_actors_locatives=mean(r.recall.trigrams.predicates_actors_locatives(nonZero));




