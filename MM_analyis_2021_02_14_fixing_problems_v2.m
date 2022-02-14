function MM_analyis_2021_02_14_fixing_problems_v2(in_path,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mother Machine Data Analysis Script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analysis mother machine movies. The current path has to be set to path with
% the images to analyze e.g. C:\Sample_Data
% 
% 1. Pre-Analysis. 
%    This script automatically rotates all images such that the mother cell, the cell
%    that is at the dead end of the growth channel is the cell closest to 
%    the top edge of the image:
%   _______________
%    |0|  |0|  |0|
%    |0|  |0|  |0|
%    |0|  |0|  |0|
%    | |  |0|  |0|
%
% 2. Segmentation.
%    This function segments the images using an edge detection algorithm on
%    the RFP channel. The resulting image is undersegmented (all cells in a
%    channel might be recognized as one). To split cells a line along
%    the centre of the channels is used to determine where the cells end.
%    In the RFP channel at the split point the line profil has a minimum.
%
% 3. Tracking.
%    All cells in the channel are tracked. For the tracking to work it is 
%    critical that the mother cells is the cell closest to the top edge of the image.
%
%
%input: 
%in_path: the path where all the data is
%todo: defines what is done. 1= Renamning, 2= Segmentation, 3= Tracking
%seg: defines which segmentation to do 1= track all cells, 2= only mother
%cell


tic;


%going though input
todo=nan;
seg=nan;
do_plot=nan;
correct_shift=nan;
if length(varargin)>0
    for i = 1:2:length(varargin),
        theparam = lower(varargin{i});
        switch(strtok(theparam)),
            case 'todo',
                todo=varargin{i+1};
            case 'seg',
                seg=varargin{i+1};
            case 'plot'
                do_plot=varargin{i+1};
            case 'shift'
                correct_shift=varargin{i+1};
        end;
    end
end

if isnan(todo)
    todo=[1:3];
end
if isnan(seg);
    seg=1;
end
if isnan(do_plot)
    do_plot=1;
end
if isnan(correct_shift)
    correct_shift=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
date1='2016-06-14';
path=in_path;
cd(in_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Pre-Analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember(1,todo);
    %Finding_channels_and_rotate_2021_10_08_v3
    Finding_channels_and_rotate_2021_11_22_v3
%     Finding_channels_and_rotate_2021_11_06_v3
    %Finding_channels_and_rotate_2021_10_08_v3('PosList',50:56);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Segmentation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd([path,'\','subAuto']);
D=dir('*p-001.tif');
if ismember(2,todo);
    parfor i=1:length(D)
        p = initschnitz(D(i).name(1:11),'2016-06-14','bacillus','rootDir',cd,'imageDir',cd);
        p = segmoviefluor_mm_para_2021_05_25_v2(p);
    end
end

%Correction shift
p = initschnitz(D(i).name(1:11),'2016-06-14','bacillus','rootDir',cd,'imageDir',cd);
if correct_shift==1
    correcting_shift_2022_02_11_v3_speedy(p);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Tracking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
what_plot='AYlen';
if exist([p.rootDir,'2021-11-03'])
    p = initschnitz('Bacillus-01','2021-11-03','bacillus','rootDir',cd,'imageDir',cd);
else
    p = initschnitz('Bacillus-01','2016-06-14','bacillus','rootDir',cd,'imageDir',cd);
end

p.dataDir=[p.rootDir,'Data\'];
if ismember(3,todo);
    if ~exist(p.dataDir)
        mkdir(p.dataDir);
    end
    D=dir('Bacillus-01-p-*');
    range=length(D);
    if ismember(seg,1)
        p=track_all_Cells_2019_06_13_v6(p,range);
    elseif ismember(seg,2);
        make_sfiles_mothercell_2022_02_11_v_bug_fixing_para(p)
        ind=calc_promo_21_11_01_BMM2(p);
        plotting_MM_data_2021_11_01_v3(p,what_plot)
    end   
end

if do_plot==1&&~ismember(3,todo);
    %Plotting AYlen
    what_plot='AYlen';
    plotting_MM_data_2021_11_05_v3_all(p,what_plot)
    saveas(gcf,[p.dataDir,in_path(end-10:end-1),'_',what_plot,'.pdf']);
    %plotting MY
    what_plot='MY';
    plotting_MM_data_2021_11_05_v3_all(p,what_plot)
    saveas(gcf,[p.dataDir,in_path(end-10:end-1),'_',what_plot,'.pdf'])
end

toc;
