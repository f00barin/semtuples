function [paths,types,flag] = genPaths_v2(graph, pred)

nT=length(graph.dep);
flag = 0;
% Path from predicate to root
ptroot=pred;
parent=graph.dep(pred);

while(parent~=0)
    ptroot=[parent ptroot];
    parent=graph.dep(parent);
    flag = 1;
end

for n=1:nT
    paths{n}=n;
    parent=graph.dep(n);
    while(parent~=pred && parent~=0)
        paths{n}=[paths{n} parent];
        parent=graph.dep(parent);
    end
    if(parent==pred)
        paths{n}=[paths{n} parent];
        types(n)=1; % ascending path
    elseif(length(ptroot)~=1) % descend (with more then pred in ptroot)
        paths{n}=[paths{n} ptroot(2:end)];
        types(n)=2;
    else % decend (with only pred in ptroot)
        paths{n}=[paths{n}];
        types(n)=2;
    end
        
end






