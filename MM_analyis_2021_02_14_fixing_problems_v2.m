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
do.rot=nan;
todo=nan;
seg=nan;
do.chip=nan;
do_plot=nan;
correct_shift=nan;
do.pos=nan;
do.frames=nan;
do.para_seg=nan;
do.para_shift=nan;
do.shift=nan;
do.shift_show=nan;
do.seg_trac=nan;
if ~isempty(varargin)
    for i = 1:2:length(varargin)
        theparam = lower(varargin{i});
        switch(strtok(theparam))
            case 'todo'
                todo=varargin{i+1};
            case 'seg'
                seg=varargin{i+1};
            case 'plot'
                do_plot=varargin{i+1};
            case 'shift'
                correct_shift=varargin{i+1};
            case 'do_pos'
                do.pos=varargin{i+1};
            case 'do_frames'
                do.frames=varargin{i+1};
            case 'do_para_seg'
                do.para_seg=varargin{i+1};
            case 'do_para_shift'
                do.para_shift=varargin{i+1}; 
            case 'do_shift'
                do.shift=varargin{i+1}; 
            case 'do_shift_show'
                do.shift_show=varargin{i+1}; 
            case 'do_seg_trac'
                do.seg_trac=varargin{i+1}; 
            case 'rot'
                do.rot=varargin{i+1}; 
            case 'chip'
                switch(strtok(lower(varargin{i+1})))
                    case 'mm15'
                        do.chip=0;
                    case 'jin'
                        do.chip=1;
                end
        end
    end
end

if isnan(do.rot)&&sum(ismember(todo,1))
    answer = questdlg('Do we have to rotate', ...
	'Rotation', ...
	'Yes','No','Cancel','Cancel');
    switch answer
        case 'Yes'
            do.rot=1;
        case 'No'
            do.rot=0;
        case 'Cancel'
            return;
    end     
end
    
if isnan(todo)
    todo=1:3;
end
if isnan(seg)
    seg=1;
end
if isnan(do_plot)
    do_plot=1;
end
if isnan(correct_shift)
    correct_shift=0;
end
if isnan(do.para_seg)
    do.para_seg=1;
end
if isnan(do.para_shift)
    do.para_shift=0;
end
if isnan(do.shift)
    do.shift=1;
end
if isnan(do.shift_show);
    do.shift_show=0;
end
if isnan(do.chip);
    do.shift_show=0;
end
if isnan(do.chip);
    do.chip=1;
end

if in_path(end)~='\'
    in_path=[in_path,'\'];
end

if isnan(do.seg_trac);
    do.seg_trac=0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
date_in='2022-03-23';
date_out='2022-04-52';
do.phase_name='w1Phase';
do.rfp_name='w2RFP - Camera';
do.yfp_name='w3YFP - Camera';
do.cfp_name=nan;
do.gfp_name=nan;


%path=in_path;
%cd(in_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Pre-Analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember(1,todo)&&do.rot==1
    %Finding_channels_and_rotate_2021_10_08_v3
%    Finding_channels_and_rotate_2021_11_22_v3(in_path,do) %old scope
    Finding_channels_and_rotate_TI2_2021_11_11_v4(in_path,do) %new scope
%     Finding_channels_and_rotate_2021_11_06_v3
    %Finding_channels_and_rotate_2021_10_08_v3('PosList',50:56);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Segmentation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%finding number of posiutions
% D=dir([in_path,'*p-001.tif']);
if isnan(do.pos)
    if ismember(1,todo)&&do.rot==1
        D=dir([in_path,'subAuto\*p-001.tif']);
        pos_do_now=1:length(D);
    else
        D=dir([in_path,'*w1*_t1.tif']);
        pos_do_now=1:length(D);
    end
else
    pos_do_now=do.pos;
end

%making folder for output
in_path=[in_path,'subAuto\'];
if ~exist(in_path,"file")
    mkdir(in_path);
end
%this is taking care of the case of more than 99 positions


if ismember(2,todo)
    %Getting position names
    %Its a case of roatated data
    [pos_names,pos_names_data]=getting_pos_names_for_seg(in_path,do);
    
    %checking if doing parallel segmentation
    if do.para_seg==1 %Case of parallel segementation
        ind_pos_do_now=1:length(pos_do_now);
        parfor ii=ind_pos_do_now
            i=pos_do_now(ii);
            p = initschnitz(pos_names{i},date_in,'bacillus','rootDir',in_path,'imageDir',in_path);
            p.movieName_file=p.movieName;
            p.movieName=pos_names_data{i};
            p.imageDir=p.imageDir(1:end-8);
            %p = segmoviefluor_mm_para_2021_05_25_v2(p,'do_pos',do.pos,'do_frames',do.frames);
            p.do=do;
            if do.rot==0
                p.imageDir=p.imageDir(1:end-8);
 %               p.movieBaseFile=movieBaseFile;
            end
            segmoviefluor_mm_para__no_renaming_2021_05_25_v2(p,do,'segRange',do.frames);
        end
    else %case of normal for loop
        while length(pos_do_now)~=0
            try
                for i=pos_do_now 
                    p = initschnitz(pos_names{i},date_in,'bacillus','rootDir',in_path,'imageDir',in_path);
                    p.movieName_file=p.movieName;
                    p.movieName=pos_names_data{i};
                    %p = segmoviefluor_mm_para_2021_05_25_v2(p,'do_pos',do.pos,'do_frames',do.frames);
                    p.imageDir=p.imageDir(1:end-8);
                    p.do=do;
                    if do.rot==0
                        p.imageDir=p.imageDir(1:end-8);
        %                p.movieBaseFile=movieBaseFile;
                    end
                    if do_seg_track==1
                        segmoviefluor_mm_para_no_renaming_one_track_2023_04_24_v1(p,do,'segRange',do.frames);
                    else
                        segmoviefluor_mm_para__no_renaming_2021_05_25_v2(p,do,'segRange',do.frames);
                    end
                end
            catch
                D=dir([in_path,'\subAuto\2022-03-23\B*']);
                names={D.name};
                names2=cellfun(@(a) str2num(a(end-2:end)),names,'UniformOutput',false);
                names3=cell2mat(names2);
                w=1; 
                clear good;
                for i=1:length(1:141)
                    if sum(names3==i)==0
                        good(w)=i; 
                        w=w+1;
                    end
                end
                pos_do_now=good;
                if length(pos_do_now)>0
                    [~,ind]=sort({D.date});
                    ns=names(ind);
                    delete([in_path,'\subAuto\2022-03-23\',ns{end}]);
                end
            end
        end
    end

        
end

%Correction shift

if correct_shift==1
    p = initschnitz(D(1).name(1:f(1)),date_in,'bacillus','rootDir',in_path,'imageDir',in_path);
    correcting_shift_2022_02_11_v3_speedy(p,date_out,do);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Tracking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
what_plot='AYlen';
% if exist([p.rootDir,'2021-11-03'])
    p = initschnitz('Bacillus-01',date_in,'bacillus','rootDir',in_path,'imageDir',in_path);
% else
%     p = initschnitz('Bacillus-01',date_out,'bacillus','rootDir',in_path,'imageDir',in_path);
% end

p.dataDir=[p.rootDir,'Data\'];
if ismember(3,todo);
    if ~exist(p.dataDir)
        mkdir(p.dataDir);
    end
    D=dir([p.rootDir,'Bacillus-01-p-*']);
    range=length(D);
    if ismember(seg,1)
        p=track_all_Cells_2019_06_13_v6(p,range);
    elseif ismember(seg,2);
        make_sfiles_mothercell_2022_02_11_v_bug_fixing_para(p,'do',do)
        ind=calc_promo_21_11_01_BMM2(p);
        plotting_MM_data_2021_11_01_v3(p,what_plot)
    end   
end

if do_plot==1&&ismember(4,todo);
    %Plotting AYlen
    what_plot='AYlen';
    plotting_MM_data_2021_11_01_v3(p,what_plot)
%    plotting_MM_data_2021_11_05_v3_all(p,what_plot)
%     saveas(gcf,[p.dataDir,in_path(end-10:end-1),'_',what_plot,'.pdf']);
    saveas(gcf,[p.dataDir,what_plot,'.pdf']);
    %plotting MY
    what_plot='MY';
    plotting_MM_data_2021_11_01_v3(p,what_plot)
%    plotting_MM_data_2021_11_05_v3_all(p,what_plot)
%     saveas(gcf,[p.dataDir,in_path(end-10:end-1),'_',what_plot,'.pdf'])
saveas(gcf,[p.dataDir,what_plot,'.pdf']);
end

toc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos_names_file,pos_names]=getting_pos_names_for_seg(in_path,do)
% This function gets the positions names. 
% Its a special case if rotation is needed.
% Input: 
% in_path: string e.g. '\\slcu.cam.ac.uk\data\Microscopy\TeamJL'
% p: path structer as definded with initschnitz
% do: structe with informatoin what to do


if do.rot==1
    %Special case if more than 100 pos
    D=dir([in_path,'*p-001.tif']);
    if length(D)>99
        names={D.name};
        f_pre=cellfun(@(a) strfind(a,'-'),names,'UniformOutput',false);
        f=cell2mat(cellfun(@(a) a(2)-1,f_pre,'UniformOutput',false));
    else
        f=ones(length(D),1)*11;
    end
    pos_names_cell={D.name};
    pos_names=cell(length(D),1);
    for i=1:length(pos_names_cell)
        pos_names{i}=pos_names_cell{i}(1:f(i));
    end
else
    D=dir([in_path(1:end-8),'*w1*_t1.tif']);
    names={D.name};
    f_pre=cellfun(@(a) strfind(a,'_'),names,'UniformOutput',false);
    f=cell2mat(cellfun(@(a) a(2)-1,f_pre,'UniformOutput',false)); 
    movie_base=names{1}(1:f_pre{1}(1)-1);
    %Removing number from basename
    matches=regexp(movie_base,'\d*','Match');
    if ~isempty(matches)
        fm=strfind(movie_base,matches{1});
        movie_base_file=movie_base(1:fm-1);
    end
    pos_names=cell(length(D),1);
    pos_names_file=cell(length(D),1);
    for i=1:length(D)
        pos_names{i}=[movie_base,'-',str3(str2double(names{i}(f_pre{i}(2)+2:f_pre{i}(3)-1)))];
        pos_names_file{i}=[movie_base_file,'-',str3(str2double(names{i}(f_pre{i}(2)+2:f_pre{i}(3)-1)))];
    end
    pos_names=sort(pos_names);
    pos_names_file=sort(pos_names_file);
end
end
