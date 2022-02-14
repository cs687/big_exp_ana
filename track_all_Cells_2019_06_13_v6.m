function p=track_all_Cells_2019_06_13_v6(p,range)
% This function tracks all cells in the channel. By matching the cells by
% their position in the channel. #1 stays number one etc. A division is
% detected if the cells shrinks by mor than 25%.
%
%input:
%p: p structure
%range: frames to analyse 
%
%output:
%p: p strucutre


%setting parameters
colors='ry';
poslist=get_poslist(p);
imgDir=p.imageDir;

%Loop over all positions
for posctr=1:length(poslist)
    p = initschnitz(poslist{posctr},p.movieDate,'bacillus','rootDir',imgDir,'imageDir',imgDir);
    run_track_all_cells_2019_06_13_v4(p,poslist,posctr,colors,range);
end
