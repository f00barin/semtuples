function score = compFscore(predicted_class, class, beta)
% 
% score.TP = sum(find(predicted_class)==find(class));
% score.FP = sum(find(predicted_class)~=find(class));
% score.TN = sum(find(abs(predicted_class-1))==find(abs(class-1)));
% score.FN = sum(find(abs(predicted_class-1))~=find(abs(class-1)));

% C = fraction of misclassification
% CM = Confusion matrix [TN FP; FN TP]
% IND = indicies of the samples in each part of CM
% PER = FN rate, FP rate, TP rate, TN rate??
class(find(class<0))=0;
predicted_class(find(predicted_class<0))=0;
[C,CM,IND,PER] = confusion(class',predicted_class');
score.CM = CM;
score.CMindicies = IND;

score.recall = CM(2,2)/(CM(2,1)+CM(2,2)); % TP/(FN+TP)
score.precision = CM(2,2)/(CM(1,2)+CM(2,2)); % TP/(FP+TP)

% F-1 score - harmonic mean
% F-2 score - higher weight on recall
score.F = (1+beta^2)*score.precision*score.recall/(beta^2*score.precision+score.recall);