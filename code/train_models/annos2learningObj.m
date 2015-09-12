function [Features,Labels,predflag] = annos2learningObj(data,fTemplates)
%% NOTES:
% for each noun::

% Features:
% role is the parser decicion; A0(agent),A1(patient),AM-LOC(locative),or '_'(none)?
% wordtype is the parser decision;'NMOD','SBJ','ROOT','VC','OBJ','OPRD','LOC',ect.
% 
%   'lexical: ' verb(path(end)) noun(path(1))
%   'lexical: ' noun(path(1))
%   'role: ' role
% SRLDATA
% if
%   if verb(path(end)) isnt pred(decided by parser, verb root)
%     '-NOpred-'
%     'semantic roles: ' '-NOpred-1' role
%   else
%     '-pred-'
%     {'semantic roles: ' '-pred-1' role} - commented out
%   end
% else
%   '-NOSRL-1'
% end
% 
% Labels:
% if noun is in agent, patient, or locative_head range
%   mark 1 in 1(agent),2(patient),3(locative_head)
% 
% Length of features and labels == # of nouns

%%
k=0;
Features=sparse(10000,length(fTemplates.feature2id));
Labels=-ones(10000,4); % AGENT, PACIENT, LOCATIVE, NONE
predflag = 0;
for i=1:length(data)
    graph=data(i).tree;
    pos=graph.pos;
    gT=data(i).gT;
    if isempty(gT.pred_range)
        continue
    end
    pred=gT.pred_range(1,1);
    if find(graph.dep==0)~=pred
        predflag = predflag+1;
        %fprintf(graph.tokens)
        %fprintf('\n root# = %1.0f ; pred# = %1.0f \n',find(graph.dep==0),pred); 
    end
    [paths,types] = genPaths_v2(graph, pred);
    cand=strmatch('NN',pos);
    for n=1:length(cand)
        k=k+1;
        flag = 0;
        [fvector] = path2fvector(paths{cand(n)},types(cand(n)),graph,fTemplates);
        Features(k,:)=fvector;
        %label=-ones(1,3);
        if(~isempty(gT.agent_range))
            if(~isempty(find(gT.agent_range==cand(n))))
                Labels(k,1)=1;
                flag = 1;
            end
        end
        if(~isempty(gT.pacient_range))
            if(~isempty(find(gT.pacient_range==cand(n))))
                Labels(k,2)=1;
                flag = 1;
            end
        end
        if(~isempty(gT.locative_head_range))
            if(~isempty(find(gT.locative_head_range==cand(n))))
                Labels(k,3)=1;
                flag = 1;
            end
        end
        if(flag~=1)
            Labels(k,4)=1;
            flag = 0;
        end
    end
end
Features=Features(1:k,:);
Labels=Labels(1:k,:);

