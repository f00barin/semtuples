function [W,learningStats]=VanillaGradient(TrainData,optParams)


% Initialize Parameters
W=sparse(TrainData.numDims,1); 
lr=optParams.stlr;
notConverged=1;
i=1;
while(i<optParams.maxIter && notConverged)
    
    
    % Update Learning Rate
    lr=lr/sqrt(i);
    % Compute Gradient with respect to k examples
    [gradient]=ComputeHingeLossGradient(TrainData,W); % must add compute L2 gradient
    
    % Update Parameter Vector W
    W=W + lr * gradient;
    
    % Project W according to the type of regularization (None,L1,L1INF,L2)
    % Only None and L2 functioning atm
    [W,oldNorm]=ProjectParameters(W,optParams.C,optParams.reg);
    learningStats.norm(i)=oldNorm;
        
    % Compute Loss
    predictions=TrainData.Features*W;
    losses=1-(predictions.* TrainData.Labels');
    mistakes=find(losses>0);
    loss=sum(losses(mistakes));
    avLoss=loss/TrainData.numPoints;
    learningStats.loss(i)=avLoss;
    if(i>1)
        if(abs(learningStats.loss(i-1)-learningStats.loss(i))<optParams.tolerance)
            notConverged=0;
        end
    end
    
    
%     report=[' Iteration = ' num2str(i) ' Loss = ' num2str(avLoss) ];
%     disp(report);
    i=i+1;
    
end