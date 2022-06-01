function make_sfiles_mothercell_2022_05_27_v1(p,varargin)




% User Settings
buff_c=35;%half cropped channels width
good_pos=0;
do.frames=nan;
do.pos=nan;
channels_do_now=nan;

if length(varargin)>0
    for i=1:2:length(varargin)
        theparam = lower(varargin{i});
        switch(strtok(theparam)),
            case 'poslist',
                good_pos=1;
                poslist=varargin{i+1};
            case 'do'
                do=varargin{i+1};
        end;
    end;
end;
 do.channels=channels_do_now;
    
imgdir = p.imageDir; % no slash at end, input the 'sub' folder
datedir= p.dateDir;
date1=p.movieDate;

colors='ry';
y_im_int=3;

%Finding basename
basenamedir = dir([imgdir filesep '*-*-y-001.tif']);
basenamesetpoints = strfind(basenamedir(1).name,'-');
basename = basenamedir(1).name(1:basenamesetpoints(1)-1);  
clear basenamedir basenamesetpoints;

%D_pos=dir('*-p-001.tif');
D_pos=dir([imgdir,date1,'\Bacillus-*']);
poslist_pre = {D_pos.name};

for i=1:length(poslist_pre)
    poslist{i}=poslist_pre{i}(1:11);
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

% now running through movies and tracking the top cell from each mask
%Checking which position to do
if isnan(do.pos)==1
    do_pos_now=1:length(poslist);
else
    do_pos_now=do.pos;
end

data=cell(1,length(do_pos_now));
if do.para_track==0
    for posctr = do_pos_now;
        data{posctr}=tracking_main_function_2022_05_30(poslist,do,posctr,imgdir,datestr,buff_c,colors);
    end
else
    parfor posctr = do_pos_now
        data{posctr}=tracking_main_function_2022_05_30(poslist,do,posctr,imgdir,datestr,buff_c,colors);
    end
end
    
if ~exist([imgdir,'Data'])
    mkdir(imgdir,'Data');
end

for i=1:length(data)
    if ~isempty(data{i})
        fname=fieldnames(data{i});
        for j=1:length(fname)
            eval([fname{j},'=data{',num2str(i),'}.(fname{',num2str(j),'});']);
        end
    end
end

all_s=whos('s_Bacillus*');
all_s={all_s.name};
data_D=dir([imgdir,'Data\']);
save([imgdir,'Data\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});
clear cell_m cell_s posctr poslist prev_sch sch_age sch_num division_detected imgdir store_sch basename ctr datestr;
%end

function data=tracking_main_function_2022_05_30(poslist,do,posctr,imgdir,datestr,buff_c,colors)
    disp(poslist(posctr));
    p = initschnitz(poslist{posctr},datestr,'bacillus','rootDir',imgdir,'imageDir',imgdir); 
    segdir = p.segmentationDir;
    trackdir = p.tracksDir;
    s = struct('frames',[],'P',[],'D',[],'E',[],'len',[],'wid',[],'MC',[],'MY',[],'MR',[],'cellno',[],'channel_pos',[]);
    D = dir([segdir '*.mat']); 
    D = {D.name};
   

    if length(D)>10;
        %checking which frames to do
        if isnan(do.frames(end))~=1&&length(D)>=do.frames(end)
           do_frames_now=1:do.frames(end);
        else
           do_frames_now=1:length(poslist);
        end

        %Loading channel pos from shift
        D_channels=dir([p.movieDir,'*.txt']);
        channels=textread([p.movieDir,D_channels(1).name]);
        if isnan(do.channels)
            channels_to_do=1:length(channels);
        else
            channels_to_do=do.channels;
        end
        
        for segctr=do_frames_now
                %Loading data
                L = load([segdir D{segctr}],'Lc','yreg','rreg');
                Lc_m = L(1).('Lc');
                yreg_m=double(L(1).('yreg'));
                rreg_m=double(L(1).('rreg'));
                disp(segctr);
            for c=channels_to_do
                if segctr==do_frames_now(1)
                    %Setting giant s
                    all(c).s=s;
                    all(c).continue=1;
                    %Saving channel number to schnitz
                    all(c).s(1).channel_pos=channels(c);
                    all(c).save_no=0;
                    all(c).sch_num = 1; 
                    all(c).sch_age = 0;
                elseif all(c).continue==0
                    %only contiune with channel if it has cells
                    continue;
                end

                %Cropping out channel
                Lc=Lc_m(:,channels(c)-buff_c:channels(c)+buff_c);
                yreg=yreg_m(:,channels(c)-buff_c:channels(c)+buff_c);
                rreg=rreg_m(:,channels(c)-buff_c:channels(c)+buff_c);

                cell_m = -100;
                cell_s = -100;
                if all(c).sch_num==1
                    all(c).s(all(c).sch_num).approved =1;
                end             
                %extract cell length & other properties
                r = regionprops(Lc,'MajorAxisLength','MinorAxisLength','Centroid');

                %find 'highest'/2nd 'highest' cell, in cell_m and cell_s(are indices to r and Lc)
                cens = vertcat(r.Centroid);
                %stop this channels if no cells
                if isempty(cens)==1
                    all(c).save_no=1;
                    all(c).continue=0;
                    continue;
                end
                cenys = sort(cens(:,2));
                %y-coordinates of mother cells
                cell_m = find(cens(:,2) == cenys(1));
                
                %y- coordinates of second highest cell
                try 
                    cell_s = find(cens(:,2) == cenys(2)); 
                catch
                end

                %Not saving this channel if there is no second highest
                %cell
                if isempty(cell_s)==1
%                     if length(s)==1
%                         all(c).save_no=1;
%                         all(c).continue=0;
%                     end
                    continue;
                end
                
                %Not saving this channel is negative
                if cell_s<=0
                    all(c).save_no=1;
                    all(c).continue=0;
                    continue;
                end
                clear cens cenys;       

                %check if cell has divided, remember we haven't updated sch_num and sch_age yet
                division_detected = 0;
                if all(c).sch_age > 1 
                    if r(cell_m).MajorAxisLength < .75*all(c).s(all(c).sch_num).len(all(c).sch_age) %if it has divided                
                        division_detected = 1;
                    end
                end

                if division_detected == 1
                    %Saving division event
                    all(c).store_sch = all(c).sch_num;
                    all(c).sch_num = length(all(c).s) + 1; %sch_num is now set to the sch of the new mother cell
                    all(c).sch_age = 1;
                    all(c).s(all(c).store_sch).D = all(c).sch_num;
                    all(c).s(all(c).sch_num).P = all(c).store_sch;            
                else %if division event not detected
                    all(c).sch_age = all(c).sch_age + 1;
                end

                % add various fields to s for mother cell                      
                all(c).s(all(c).sch_num).frames(all(c).sch_age) = segctr;                 
                all(c).s(all(c).sch_num).len(all(c).sch_age) = r(cell_m).MajorAxisLength;
                all(c).s(all(c).sch_num).wid(all(c).sch_age) = r(cell_m).MinorAxisLength;          
                all(c).s(all(c).sch_num).cellno(all(c).sch_age) = cell_m;
                all(c).s(all(c).sch_num).cenx(all(c).sch_age) = r(cell_m).Centroid(1);
                all(c).s(all(c).sch_num).ceny(all(c).sch_age) = r(cell_m).Centroid(2);

                % add fluorescence properties to s for mother cell, by first loading yreg,creg, for mother cell
                %try
                if sum(ismember(colors,'y'))
                    all(c).s(all(c).sch_num).MY(all(c).sch_age) = mean(yreg(Lc == cell_m));
                end
                if sum(ismember(colors,'c'))
                    all(c).s(all(c).sch_num).MC(all(c).sch_age) = mean(creg(Lc == cell_m));
                end
                if sum(ismember(colors,'r'))
                    all(c).s(all(c).sch_num).MR(all(c).sch_age) = mean(rreg(Lc == cell_m));
                end

                % below is all code pertaining to the mother cell's other daughter
                if division_detected == 1
                    %setting output
                    all(c).sch_num = length(all(c).s) + 1; %sch_num is now set to the lineage of the mother's other daughter
                    all(c).s(all(c).sch_num).approved =1;
                    all(c).s(all(c).sch_num).P = all(c).store_sch; %a bit confusing...
                    all(c).s(all(c).store_sch).E = all(c).sch_num; %a bit confusing...
                    all(c).s(all(c).sch_num).frames = segctr;            
                    all(c).s(all(c).sch_num).len(all(c).sch_age) = r(cell_s).MajorAxisLength;
                    all(c).s(all(c).sch_num).wid(all(c).sch_age) = r(cell_s).MinorAxisLength;  
                    all(c).s(all(c).sch_num).cellno(all(c).sch_age) = cell_s;
                    all(c).s(all(c).sch_num).cenx(all(c).sch_age) = r(cell_s).Centroid(1);
                    all(c).s(all(c).sch_num).ceny(all(c).sch_age) = r(cell_s).Centroid(2);
                    all(c).s(all(c).sch_num).MY(all(c).sch_age) = mean(yreg(Lc == cell_s));

                    %Saving colors
                    if sum(ismember(colors,'c'))
                        all(c).s(all(c).sch_num).MC(all(c).sch_age) = mean(creg(Lc == cell_s));
                    end
                    if sum(ismember(colors,'r'))
                        all(c).s(all(c).sch_num).MR(all(c).sch_age) = mean(rreg(Lc == cell_s));
                    end
                    all(c).sch_num = all(c).sch_num - 1; %sch_num is now reset to the mother cell's main daughter
                    all(c).s(all(c).sch_num).approved =1;
                end
                %saving movie info
                all(c).s(1).segmentationDir = p.segmentationDir;
                all(c).s(1).movieName = p.movieName;
                
                %saving last frame daughter 
                if segctr==do_frames_now
                    for ctr = 1:length(all(c).s)
                        if isempty(all(c).s(ctr).D); 
                            all(c).s(ctr).D = 0; 
                        end;
                        if isempty(all(c).s(ctr).E); 
                            all(c).s(ctr).E = 0; 
                        end;
                    end
                end 
                clear Lc_c yreg_c creg_c rreg_c
            end
        end

    end
%     for save_chan=channels_to_do
%         if all(save_chan).save_no==0
%                     %eval(['s_'  strrep(poslist{posctr},'-','_'), '_', str2(save_chan), ' = all(',num2str(save_chan),').s;']);
%                     eval(['data.','s_'  strrep(poslist{posctr},'-','_'), '_', str2(save_chan), ' = all(',num2str(save_chan),').s;']);
%                     %assignin('caller',['s_'  strrep(poslist{posctr},'-','_'), '_', str2(save_chan)],s);
%                     %eval(['s_'  strrep(poslist{posctr},'-','_'), '_', str2(save_chan), ' = all(',num2str(save_chan),').s;']);
%         end
%     end
    if ~exist('data','var')
        data=[];
    end
