function[precision,recall,f1] = getMeasures(n_predictions,n_gold,n_correct)

if(n_predictions==0)
    precision=1;
else
    precision=n_correct/n_predictions;
end

if(n_gold==0)
    recall=1;
else
    recall=n_correct/n_gold;
end

if(precision+recall==0)
    f1=0;
else
    f1=2*(precision*recall/(precision+recall));
end