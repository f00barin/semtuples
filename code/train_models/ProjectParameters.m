function[W,oldNorm]=ProjectParameters(W,C,regType)


oldNorm=0;
switch regType
    case 'None'
%       disp('No Regularization');
    case 'L2'
%       disp('L2 Regularization');  
      for i=1:size(W,2)
          if(norm(W(:,i))>C)
            W(:,i)=W(:,i)./norm(W(:,i));
            W(:,i)=W(:,i)*C;
          end
      end
    case 'L1'
        disp('L1 Regularization');
        weights=ones(length(W),1);
        oldNorm=sum(sum((abs(W))));
        for i=1:size(W,2)     
            wtask=full(W(:,i));
            normL1=sum(abs(wtask));
            if(normL1>C)
             [wtask]=projectL1Inf(wtask,C,weights);
            end
            W(:,i)=sparse(wtask);
        end
     
            
    case 'L1INF'
        disp('L1INF Regularization');
        weights=ones(length(W),1);
        oldNorm=sum(max(abs(W')));
        [W]=projectL1Inf(full(W),C,weights);
        W=sparse(W);
   otherwise
      disp('Unknown Regularization Type');
end