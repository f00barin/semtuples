function [arguments] = line2arguments(line)

[annosID foo]=strtok(line,'@');
arguments.annosID=str2num(annosID);

beg=strfind(line,'FNAME')+length('FNAME')+1;
ending=strfind(line,'PRED')-length('PRED');
ending2 = strfind(line,'PRED')-2;
arguments.imageFile=line(beg:ending);
arguments.capnum = line(beg:ending2);

beg=strfind(line,'PRED')+length('PRED')+1;
ending=strfind(line,'A0')-2;
arguments.pred=line(beg:ending);

beg=strfind(line,'A0')+length('A0')+1;
ending=strfind(line,'A1')-2;
arguments.agent=line(beg:ending);
     
beg=strfind(line,'A1')+length('A1')+1;
ending=strfind(line,'LOC_HEAD')-2;
arguments.pacient=line(beg:ending);

beg=strfind(line,'LOC_HEAD')+length('LOC_HEAD')+1;
ending=strfind(line,'LOC_PREP')-2;
arguments.loc_head=line(beg:ending);
    
beg=strfind(line,'LOC_PREP')+length('LOC_PREP')+1;
ending=strfind(line,'LOC_TYPE')-2;
arguments.loc_prep=line(beg:ending);
    
