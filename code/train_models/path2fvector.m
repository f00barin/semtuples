function [fvector] = path2fvector(path,type,graph,fTemplates)

fvector=sparse(length(fTemplates.feature2id),1);
% lexical feature
f=['lexical: ' graph.lemmas{path(end)} ' ' graph.lemmas{path(1)}];
if(fTemplates.feature2id.isKey(f))
    fvector(fTemplates.feature2id(f))=1;
end

f=['lexical: ' graph.lemmas{path(1)}];
if(fTemplates.feature2id.isKey(f))
    fvector(fTemplates.feature2id(f))=1;
end
     
% semantic role features
arguments=graph.predicates_arg;
predicates=graph.predicates;
if(~isempty(predicates))
    cols=strfind(predicates,'-');
    argids=zeros(length(cols),1);
    id=0;
    for j=1:length(cols)
        if(isempty(cols{j}))
            id=id+1;
            argids(j)=id;
        end
    end
    if(strcmp(predicates{path(end)},'-'))
        f='-NOpred-1';
        if(fTemplates.feature2id.isKey(f))
            fvector(fTemplates.feature2id(f))=1;
        end

        for col=1:length(arguments)
            role=strtrim(arguments{col}{path(1)});
            f=['role_1: ' role];
            if(fTemplates.feature2id.isKey(f))
                fvector(fTemplates.feature2id(f))=1;
            end
%             if(~isempty(arguments))
%                 role=strtrim(arguments{i}{path(1)});
                f=['semantic roles_1: ' '-NOpred- ' role];
                if(fTemplates.feature2id.isKey(f))
                    fvector(fTemplates.feature2id(f))=1;
                end
%             end
        end
    else
        f='-pred-1';
        if(fTemplates.feature2id.isKey(f))
            fvector(fTemplates.feature2id(f))=1;
        end
        col=argids(path(end));
        role=strtrim(arguments{col}{path(1)});
        f=['role_1: ' role];
            if(fTemplates.feature2id.isKey(f))
                fvector(fTemplates.feature2id(f))=1;
            end
%         f=['semantic roles_1: ' '-pred- ' role];
%         if(fTemplates.feature2id.isKey(f))
%             fvector(fTemplates.feature2id(f))=1;
%         end
    end
else
    f='-NOSRL-1';
    if(fTemplates.feature2id.isKey(f))
            fvector(fTemplates.feature2id(f))=1;
    end
end
    
    
% path type
if (type==1)
    t='asc';
else
    t='asc-dec';
end
f=['path-type: ' t];
if(fTemplates.feature2id.isKey(f))
    fvector(fTemplates.feature2id(f))=1;
end

% path length
l=length(path);
if(l<=1)
    pl='<=1';
elseif(l<=2)
    pl='<=2';
elseif(l<=3)
    pl='<=3';
elseif(l<=4)
    pl='<=4';
else
    pl='>4';
end
f=['path-l: ' pl];
if(fTemplates.feature2id.isKey(f))
    fvector(fTemplates.feature2id(f))=1;
end
% syntactic features
deps=graph.dep_labels; 
for d=1:length(deps)
    f=['syn: ' deps{d} ' ' t  ' ' pl];
    if(fTemplates.feature2id.isKey(f))
        fvector(fTemplates.feature2id(f))=1;
    end
    f=['syn: ' deps{d}];
    if(fTemplates.feature2id.isKey(f))
        fvector(fTemplates.feature2id(f))=1;
    end
end
for d=1:length(path)
    f=['syn-inpath: ' deps{path(d)} ' ' t  ' ' pl];
    if(fTemplates.feature2id.isKey(f))
        fvector(fTemplates.feature2id(f))=1;
    end
    f=['syn-inpath: ' deps{path(d)}];
    if(fTemplates.feature2id.isKey(f))
        fvector(fTemplates.feature2id(f))=1;
    end
end










