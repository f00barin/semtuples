function[g]=ComputeHingeLossGradient(D,W)

predictions=D.Features*W;
losses=1-(predictions.* D.Labels'); %is this in the correct order?
mistakes=find(losses>0);
g=D.Labels(mistakes)*D.Features(mistakes,:);
g=g'/D.numPoints;

