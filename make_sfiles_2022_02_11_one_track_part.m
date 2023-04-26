function make_sfiles_2022_02_11_one_track_part(p,varargin)
% User Settings
do.frames=nan;
do.pos=nan;

if ~isempty(varargin)
    for i=1:2:length(varargin)
        theparam = lower(varargin{i});
        switch(strtok(theparam))
            case 'poslist'
                %good_pos=1;
                poslist=varargin{i+1};
            case 'do'
                do=varargin{i+1};
        end
    end
end
               
do=setting_parameter_4_track(do);

imgdir = p.imageDir; % no slash at end, input the 'sub' folder
date1=p.movieDate;
%y_im_int=3;

%Finding basename
% basenamedir = dir([imgdir filesep '*-*-y-001.tif']);
% basenamesetpoints = strfind(basenamedir(1).name,'-');
% basename = basenamedir(1).name(1:basenamesetpoints(1)-1);  
% clear basenamedir basenamesetpoints;

%D_pos=dir('*-p-001.tif');
D_pos=dir([imgdir,date1,'\Bacillus-*']);
poslist_pre = {D_pos.name};

for i=1:length(poslist_pre)
    poslist{i}=poslist_pre{i}(1:end);
end
%poslist = {D_pos.name}; %as string, e.g. {'01_1' '01_2' '01_3' '02_1'}


                                                                
% More specifically, the code uses the above info to look for the segmentation directory.
% For instance, it will look for a directory like [imgdir filesep '2015-07-07' filesep 'dude' poslist{1} filesep 'segmentation']
%                                             e.g. D:\2015-07-07-mothermachine\sub\2015-07-07\dude01_1\segmentation
% Note the 'date folder', e.g. a folder named '2015-07-07', is found automatically. The basename, e.g. dude, is also found automatically

%
%Find datefolder name
D = dir([imgdir filesep p.movieDate,'*']); 
D = D(vertcat(D.isdir));
if length(D) ~= 1
    error('Either a date directory was not found in the sub folder, or there was more than 1 identified date folder');
end
datestr = D(1).name; 
clear D;



%Check directory
% if ~strcmp(cd,imgdir)
%     error('current directory and the user'' inputted directory are different');
% end

% now running through movies and tracking the top cell from each mask
%Checking which position to do
if isnan(do.pos)==1
    do_pos_now=1:length(poslist);
else
    do_pos_now=do.pos;
end

mkdir(imgdir,'Data');
for posctr = do_pos_now;
    disp(poslist(posctr));
    %init post
    p = initschnitz(poslist{posctr},datestr,'bacillus','rootDir',imgdir,'imageDir',imgdir); 
    segdir = p.segmentationDir;
    
    D = dir([segdir '*.mat']); 
    D = {D.name};

    if length(D)>10;
        if isnan(do.frames(end))~=1&&length(D)>=do.frames(end)
            do_frames_now=1:do.frames(end);
        else
           do_frames_now=1:length(D);
        end

        %Better channel cropping
         %imshow(Lc); 
        load([segdir D{1}],'Lc');
        channels=getting_channels(p,Lc);

        if length(channels)<=30
                p = initschnitz(poslist{posctr},datestr,'bacillus','rootDir',imgdir,'imageDir',imgdir); 
                segdir = p.segmentationDir;
                D = dir([segdir '*.mat']); 
                D = {D.name};
%                 trackdir = p.tracksDir;

                % loop thru all seg files, listed in 'D', and extract data. 
                % assume the 'highest' cell in each frame is the mother cell
                all_data=cell(length(channels),1);
                for segctr =do_frames_now
                    p.segctr=segctr;
                    p.channels=channels;
                    if segctr>1
                        good_c_cell=cellfun(@(a) a(1).done,all_data,'UniformOutput',false);
                        good_c=sum(cell2mat(good_c_cell));
                        if good_c==length(channels);
                            p.continue=0;
                            %return;
                            break;
                        end
                    end
                    %loading frame into memory
                    Lc_a = load([segdir D{segctr}],'Lc');
                    Lc_m=Lc_a.Lc;
                    yreg_a = load([segdir D{segctr}],'yreg');
                    yreg_m=yreg_a.yreg;
                    rreg_a = load([segdir D{segctr}],'rreg');
                    rreg_m=rreg_a.rreg;
                    all_data=tracking_main_low_memory_2023_04_05_v1(p,do,all_data,Lc_m,rreg_m,yreg_m,poslist);
                end
                
        end
        clear Lc_m yreg_m reg_m rreg_m Lc_c yreg_c creg_c rreg_c;
        %clear segctr D ctr segdir p s;
    end
% end

saving_tracking_data(p,all_data);
%     catch
%          disp(['Problem ']);
%     end
end

%loading all files into memory
saving_all_tracking_data(p)



% function tracking_main_low_memory()