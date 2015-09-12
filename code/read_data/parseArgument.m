function [argument_range] = parseArgument(argumentString)

id=1;
argument={};
while(~isempty(argumentString))
    [arg argumentString]=strtok(argumentString);   
    argument{id}=arg(2:end-1);
    id=id+1;
end

argument_range=zeros(length(argument),1);
for j=1:length(argument)
    range=argument{j};
    if(isempty(strfind(range,'-')))
        argument_range(j,1)=str2num(range);
        argument_range(j,2)=str2num(range);
    else
        [r1 r2]=strtok(range,'-');
        r2=r2(2:end);
        argument_range(j,1)=str2num(r1);
        argument_range(j,2)=str2num(r2);
    end
end