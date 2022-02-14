function poslist=get_poslist(p)
%This function gets names of the pad positions and outputs them into
%poslist.

imgdir=p.imageDir;
date1= p.movieDate;
%Finding basename
basenamedir = dir([imgdir filesep '*-*-y-001.tif']);
basenamesetpoints = strfind(basenamedir(1).name,'-');
basename = basenamedir(1).name(1:basenamesetpoints(1)-1);  
clear basenamedir basenamesetpoints;

D_pos=dir([imgdir,date1,'\Bacillus-*']);
poslist_pre = {D_pos.name};

for i=1:length(poslist_pre)
    poslist{i}=poslist_pre{i}(1:11);
end
