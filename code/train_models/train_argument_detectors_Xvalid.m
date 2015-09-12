function [model,results,fscore,testFeatures,testLabels_real]=train_argument_detectors_Xvalid(labeledData,recall_th,testData,instance,spec)
colors = {'red','black','green','cyan','magenta','yellow','blue'};

% load('featuredata.mat','fTemplates','TrainData','trainLabels','testFeatures','testLabels_real')
[fTemplates] = generateFeatureTemplates(labeledData);
[trainFeatures,trainLabels] = annos2learningObj(labeledData,fTemplates);

if(~isempty(testData))
    [testFeatures,testLabels_real] = annos2learningObj(testData,fTemplates);
end

TrainData.Features=trainFeatures;
TrainData.numPoints=size(TrainData.Features,1);
TrainData.numDims=size(TrainData.Features,2);
TrainData.activeSamples=1:TrainData.numPoints;
TrainData.mask=ones(TrainData.numPoints,1);

optParams.maxIter=100;
optParams.stlr=1;
optParams.tolerance=1.0e-08;
optParams.reg='L2';

% 10 fold cross validation
sectionlen = floor(size(TrainData.Features,1)/10);
for i=1:10
    fprintf('cross validation round %i \n',i)
    section=[(i-1)*sectionlen+1;i*sectionlen+1];
    if section(2)>size(TrainData.Features,1)
        section(2)=size(TrainData.Features,1);
    end
    Vvalidate.Features = TrainData.Features(section(1):section(2),:);
    
    if section(1)==1
        Vtraining.Features = TrainData.Features(section(2)+1:end,:);
    elseif section(2)>=length(TrainData.Features)-10
        Vtraining.Features = TrainData.Features(1:section(1)-1,:);
    else
        Vtraining.Features = [TrainData.Features(1:section(1)-1,:);TrainData.Features(section(2)+1:end,:)];
    end
    Vtraining.numPoints = size(Vtraining.Features,1);
    Vtraining.numDims = size(Vtraining.Features,2);
    Vvalidate.numPoints = size(Vvalidate.Features,1);
    Vvalidate.numDims = size(Vvalidate.Features,2);
     % Train Detectors
    % AGENT
    if section(1)==1
        Vtraining.Labels = trainLabels(section(2)+1:end,1)';
    elseif section(2)>=length(TrainData.Features)-10
        Vtraining.Labels = trainLabels(1:section(1)-1,1)';
    else
        Vtraining.Labels = [trainLabels(1:section(1)-1,1)' trainLabels(section(2)+1:end,1)'];
    end
    optParams.C=0.7;
    [w_agent]=VanillaGradient(Vtraining,optParams);
    % PACIENT
    if section(1)==1
        Vtraining.Labels = trainLabels(section(2)+1:end,2)';
    elseif section(2)>=length(TrainData.Features)-10
        Vtraining.Labels = trainLabels(1:section(1)-1,2)';
    else
        Vtraining.Labels = [trainLabels(1:section(1)-1,2)' trainLabels(section(2)+1:end,2)'];
    end
    optParams.C=0.9;
    [w_pacient]=VanillaGradient(Vtraining,optParams);
    % LOCATIVE
    if section(1)==1
        Vtraining.Labels = trainLabels(section(2)+1:end,3)';
    elseif section(2)>=length(TrainData.Features)-10
        Vtraining.Labels = trainLabels(1:section(1)-1,3)';
    else
        Vtraining.Labels = [trainLabels(1:section(1)-1,3)' trainLabels(section(2)+1:end,3)'];
    end
    optParams.C=0.6;
    [w_locative]=VanillaGradient(Vtraining,optParams);
    % NONE
    if section(1)==1
        Vtraining.Labels = trainLabels(section(2)+1:end,4)';
    elseif section(2)>=length(TrainData.Features)-10
        Vtraining.Labels = trainLabels(1:section(1)-1,4)';
    else
        Vtraining.Labels = [trainLabels(1:section(1)-1,4)' trainLabels(section(2)+1:end,4)'];
    end
    optParams.C=0.7;
    [w_NONE]=VanillaGradient(Vtraining,optParams);

    
     % EVALUATE ON TEST
    testLabels=trainLabels(section(1):section(2),:);
    % AGENT
    scores=Vvalidate.Features*w_agent;
    testClass = testLabels(:,1);
    testClass(testClass<0)=0;
%     figure(1);
%     title('AGENT AROC TEST');
%     hold on;
    [results.aroc_agent_train, results.falseAlarmRate_agent_train(i,:), results.detectionRate_agent_train(i,:)] = areaROC(scores, testClass);
%     hold off;
    %[aroc.agent_train]=ComputeAROC(TrainData,w_agent);
%     figure(2);
%     title('AGENT PREC-RECALL TEST');
%     hold on;
    [results.recall_agent_train(i,:), results.precision_agent_train(i,:), results.th_agent_train, results.area_agent_train] = precisionRecall(scores, testClass);
%     hold off;
    class_ag = scores;

    % PACIENT
    scores=Vvalidate.Features*w_pacient;
    testClass=testLabels(:,2);
    testClass(testClass<0)=0;
%     figure(3); hold on;
%     title('PACIENT AROC TEST');
    [results.aroc_pacient_train, results.falseAlarmRate_pacient_train(i,:), results.detectionRate_pacient_train(i,:)] = areaROC(scores, testClass);
%     hold off;
%     figure(4);hold on;
%     title('PACIENT PREC-RECALL TEST ');
    [results.recall_pacient_train(i,:), results.precision_pacient_train(i,:), results.th_pacient_train, results.area_pacient_train] = precisionRecall(scores, testClass);
%     hold off;
    class_pat = scores;

    % LOCATIVE
    scores=Vvalidate.Features*w_locative;
    testClass=testLabels(:,3);
    testClass(testClass<0)=0;
%     figure(5);hold on;
%     title('LOCATIVE AROC TEST');
    [results.aroc_locative_train, results.falseAlarmRate_locative_train(i,:), results.detectionRate_locative_train(i,:)] = areaROC(scores, testClass);
%     hold off;
%     figure(6);hold on;
%     title('LOCATIVE PREC-RECALL TEST');
    [results.recall_locative_train(i,:), results.precision_locative_train(i,:), results.th_locative_train, results.area_locative_train] = precisionRecall(scores, testClass);
%     hold off;
    class_loc = scores;

    % NONE
    scores=Vvalidate.Features*w_NONE;
    testClass=testLabels(:,4);
    testClass(testClass<0)=0;
%     figure(7);hold on;
%     title('NONE AROC TEST');
    [results.aroc_NONE_train, results.falseAlarmRate_NONE_train(i,:), results.detectionRate_NONE_train(i,:)] = areaROC(scores, testClass);
%     hold off;
%     figure (8);hold on;
%     title('NONE PREC-RECALL TEST');
    [results.recall_NONE_train(i,:), results.precision_NONE_train(i,:), results.th_NONE_train, results.area_NONE_train] = precisionRecall(scores, testClass);
%     hold off;
    class_NONE = scores;
    
    cSave_ag = class_ag;
    cSave_pat = class_pat;
    cSave_loc = class_loc;
    cSave_NONE = class_NONE;

    r=find(results.recall_agent_train(i,:)>=recall_th(1));
    th.agent=results.th_agent_train(r(end));
    r=find(results.recall_pacient_train(i,:)>=recall_th(2));
    th.pacient=results.th_pacient_train(r(end));
    r=find(results.recall_locative_train(i,:)>=recall_th(3));
    th.locative=results.th_locative_train(r(end));
    r=find(results.recall_NONE_train(i,:)>=recall_th(4));
    th.NONE=results.th_NONE_train(r(end));

    class_ag(find(cSave_ag<=th.agent)) = -1;
    class_ag(find(cSave_ag>th.agent)) = 1;
    class_pat(find(cSave_pat<=th.pacient)) = -1;
    class_pat(find(cSave_pat>th.pacient)) = 1;
    class_loc(find(cSave_loc<=th.locative)) = -1;
    class_loc(find(cSave_loc>th.locative)) = 1;
    class_NONE(find(cSave_NONE<=th.NONE)) = -1;
    class_NONE(find(cSave_NONE>th.NONE)) = 1;

    beta = 1;
    % -----------------------------------------------------
    fscore(i).ag = compFscore(class_ag, testLabels(:,1), beta); % manually set to f-1 score
    fscore(i).pat = compFscore(class_pat, testLabels(:,2), beta); % manually set to f-1 score
    fscore(i).loc = compFscore(class_loc, testLabels(:,3), beta); % manually set to f-1 score
    fscore(i).NONE = compFscore(class_NONE, testLabels(:,4), beta); % manually set to f-1 score

    model(i).w_agent=w_agent;
    model(i).w_pacient=w_pacient;
    model(i).w_locative=w_locative;
    model(i).w_NONE = w_NONE;
    model(i).th=th;
    model(i).fTemplates=fTemplates;
end

% plots
figure(1); hold on
title('AGENT AROC TRAIN');
plot(mean(results.falseAlarmRate_agent_train,1), mean(results.detectionRate_agent_train,1),[colors{instance} '-']); axis([0 1 0 1])
grid on; ylabel('true positive rate'); xlabel('true negative rate'); axis('square')
hold off;
figure(2); hold on
title('AGENT PREC-RECALL TRAIN');
plot(mean(results.recall_agent_train,1), mean(results.precision_agent_train,1),[colors{instance} '-']); axis([0 100 0 100])
grid on; ylabel('Precision'); xlabel('Recall'); axis('square')
hold off;

figure(3); hold on
title('PATIENT AROC TRAIN');
plot(mean(results.falseAlarmRate_pacient_train,1), mean(results.detectionRate_pacient_train,1),[colors{instance} '-']); axis([0 1 0 1])
grid on; ylabel('true positive rate'); xlabel('true negative rate'); axis('square')
hold off;
figure(4); hold on
title('PATIENT PREC-RECALL TRAIN');
plot(mean(results.recall_pacient_train,1), mean(results.precision_pacient_train,1),[colors{instance} '-']); axis([0 100 0 100])
grid on; ylabel('Precision'); xlabel('Recall'); axis('square')
hold off;

figure(5); hold on
title('LOCATIVE ROC TRAIN');
plot(mean(results.falseAlarmRate_locative_train,1), mean(results.detectionRate_locative_train,1),[colors{instance} '-']); axis([0 1 0 1])
grid on; ylabel('true positive rate'); xlabel('true negative rate'); axis('square')
hold off;
figure(6); hold on
title('LOCATIVE PREC-RECALL TRAIN');
plot(mean(results.recall_locative_train,1), mean(results.precision_locative_train,1),[colors{instance} '-']); axis([0 100 0 100])
grid on; ylabel('Precision'); xlabel('Recall'); axis('square')
hold off;

figure(7); hold on
title('NULL AROC TRAIN');
plot(mean(results.falseAlarmRate_NONE_train,1), mean(results.detectionRate_NONE_train,1),[colors{instance} '-']); axis([0 1 0 1])
grid on; ylabel('true positive rate'); xlabel('true negative rate'); axis('square')
hold off;
figure(8); hold on
title('NULL PREC-RECALL TRAIN');
plot(mean(results.recall_NONE_train,1), mean(results.precision_NONE_train,1),[colors{instance} '-']); axis([0 100 0 100])
grid on; ylabel('Precision'); xlabel('Recall'); axis('square')
hold off;