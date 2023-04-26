function make_sfiles_mothercell_2022_02_11_v_bug_fixing_para_one_track(p,varargin)




% User Settings
% clear all; close all;
% 
% imgdir ='C:\Users\Chris\Desktop\test_mm\2\2\subAuto'; % no slash at end, input the 'sub' folder
% datedir= 'C:\Users\Chris\Desktop\test_mm\2\2\subAuto\2016-06-14';
%getting varagin
%good_pos=0;

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
               
if do.chip==1
    do.buffer=100;
    do.buffer_crop=100;
else
    do.buffer=20;
    do.buffer_crop=20;
end

imgdir = p.imageDir; % no slash at end, input the 'sub' folder
%datedir= p.dateDir;
date1=p.movieDate;

colors='ry';
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
        Lc_m=Lc;
        edge_line=sum(Lc_m,2);
        edge_cand=edge_line>max(edge_line)/2;
        f=find(edge_cand);
        Lc1=logical(Lc_m(:,:,1));
        if f(1)+200<size(Lc_m,1)
            [~,channels]=findpeaks(mean(Lc1(1:f(1)+200,:,1)),'MinPeakDistance',do.buffer);
        else
            [~,channels]=findpeaks(mean(Lc1(end-200:end,:,1)),'MinPeakDistance',do.buffer);
        end
        good_channels=channels>do.buffer_crop+1&channels<size(Lc1,2)-do.buffer_crop;
        channels=channels(good_channels);
        save([p.tracksDir,'channels.mat'],'channels');
        
        %makeing control figure;
        figure(100); 
        imshow(Lc);
        vline(channels,'r');
        set(gcf, 'InvertHardCopy', 'off');
        a=size(Lc_m);
        text(a(2)*0.4,a(1)*0.05,poslist(posctr),'color','w','FontSize',20);
        saveas(gcf,[p.tracksDir,'channel_crop.png']);
        close(figure(100));
        clear('Lc1','Lc_m');

        if length(channels)<=30
                p = initschnitz(poslist{posctr},datestr,'bacillus','rootDir',imgdir,'imageDir',imgdir); 
                segdir = p.segmentationDir;
                D = dir([segdir '*.mat']); 
                D = {D.name};
                trackdir = p.tracksDir;

                % loop thru all seg files, listed in 'D', and extract data. 
                % assume the 'highest' cell in each frame is the mother cell
                all_data=cell(length(channels),1);
                for segctr =do_frames_now
                    if segctr>1
                        good_c_cell=cellfun(@(a) a(1).done,all_data,'UniformOutput',false);
                        good_c=sum(cell2mat(good_c_cell));
                        if good_c==length(channels);
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

                    %looping over channels
                    for c=1:length(channels)
                        %defining sturcutre for first frame
                        if segctr == do_frames_now(1)
                            %declare the s structure
                            s = struct('frames',[],'P',[],'D',[],'E',[],'len',[],'wid',[],'MC',[],'MY',[],'MR',[],'cellno',[],'channel_pos',[]);
                            sch_num = 1; 
                            sch_age = 0;
                            s.channel_pos=channels(c);
                            s(1).segmentationDir = p.segmentationDir;
                            s(1).movieName = p.movieName;
                            s(1).done=0;
                        else
                            s=all_data{c};
                            sch_num=s(1).sch_num;
                            sch_age=s(1).sch_age;
                        end

                        %checking if this channel has terminated
                        if s(1).done==0
                            % cropping channel
                            Lc=Lc_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);
                            yreg=yreg_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);
                            rreg=rreg_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);
    
                            save_no=0;
                            %resetting variables....why is this necessary?
                            cell_m = -100;
                            cell_s = -100;
    
                            if sch_num==1
                                s(sch_num).approved =1;
                            end             
                            %extract cell length & other properties
                            r = regionprops(Lc,'MajorAxisLength','MinorAxisLength','Centroid');
        
                            %find 'highest'/2nd 'highest' cell, in cell_m and cell_s(are indices to r and Lc)
                            cens = vertcat(r.Centroid);
                            if isempty(cens)==1
                                break;
                            end
                            cenys = sort(cens(:,2));
                            cell_m = find(cens(:,2) == cenys(1));
        
                            try cell_s = find(cens(:,2) == cenys(2)); catch; end;
                            if isempty(cell_s)==1
                                if length(s)==1
                                    save_no=1;
                                end
                                break;
                            end
                            if cell_s<=0
                                save_no=1;
                                break;
                            end
                            clear cens cenys;       
        
                            %debugging code
                            %disp([cell_m cell_s]);
                            %close all; myfig = figure; imshow(Lc,[]); impixelinfo; figure(myfig);
                            %s;
        
                            %check if cell has divided, remember we haven't updated sch_num and sch_age yet
                            division_detected = 0;
                            if sch_age > 1 
                                if r(cell_m).MajorAxisLength < .75*s(sch_num).len(sch_age) %if it has divided                
                                    division_detected = 1;
                                end
                            end
        
                            if division_detected == 1
                                store_sch = sch_num;
                                sch_num = length(s) + 1; %sch_num is now set to the sch of the new mother cell
                                sch_age = 1;
        
                                s(store_sch).D = sch_num;
                                s(sch_num).P = store_sch;            
                            else %if division event not detected
                                sch_age = sch_age + 1;
                            end
        
                            % add various fields to s for mother cell                      
                            s(sch_num).frames(sch_age) = segctr;                 
                            s(sch_num).len(sch_age) = r(cell_m).MajorAxisLength;
                            s(sch_num).wid(sch_age) = r(cell_m).MinorAxisLength;          
                            s(sch_num).cellno(sch_age) = cell_m;
                            s(sch_num).cenx(sch_age) = r(cell_m).Centroid(1);
                            s(sch_num).ceny(sch_age) = r(cell_m).Centroid(2);
        
                            % add fluorescence properties to s for mother cell, by first loading yreg,creg, for mother cell
                            %try
                            if sum(ismember(colors,'y'))
                                %yreg = load([segdir D{segctr}],'yreg'); yreg = double(yreg(1).('yreg'));
                                %yreg=yreg_c(:,:,segctr);
                                %yreg= s_int.s_c.yreg;
                                s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_m));
                            end
                            if sum(ismember(colors,'c'))
                                %creg = load([segdir D{segctr}],'creg'); creg =
                                %creg = creg_c(:,:,segctr);
                                %creg= s_int.s_c.creg;
                                s(sch_num).MC(sch_age) = mean(creg(Lc == cell_m));
                            end
                            if sum(ismember(colors,'r'))
                                %rreg = load([segdir D{segctr}],'rreg'); rreg = double(rreg(1).('rreg'));
                                %rreg =rreg_c(:,:,segctr);
                                %rreg= s_int.s_c.rreg;
                                s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_m));
                            end
        
                            % below is all code pertaining to the mother cell's other daughter
                            if division_detected == 1        
                                sch_num = length(s) + 1; %sch_num is now set to the lineage of the mother's other daughter
                                s(sch_num).approved =1;
                                s(sch_num).P = store_sch; %a bit confusing...
                                s(store_sch).E = sch_num; %a bit confusing...
                                s(sch_num).frames = segctr;            
                                s(sch_num).len(sch_age) = r(cell_s).MajorAxisLength;
                                s(sch_num).wid(sch_age) = r(cell_s).MinorAxisLength;  
                                s(sch_num).cellno(sch_age) = cell_s;
                                s(sch_num).cenx(sch_age) = r(cell_s).Centroid(1);
                                s(sch_num).ceny(sch_age) = r(cell_s).Centroid(2);
                                %try
                                %if sum(ismember(colors,'y')) && mod(segctr+y_im_int-1,y_im_int)==0
                                    %yreg = load([segdir D{segctr}],'yreg'); yreg = double(yreg(1).('yreg'));
        
                                    %yreg=yreg_c(:,:,segctr); commented out 2022.02.11
                                    %yreg= s_int.s_c.yreg;
                                    s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_s));
                                %else
                                 %   s(sch_num).MY(sch_age)=0;
                                %catch
                               % end
                                %try 
                                if sum(ismember(colors,'c'))
                                    %creg = creg_c(:,:,segctr);
                                    %creg = load([segdir D{segctr}],'creg'); creg = double(creg(1).('creg'));
                                    %creg= s_int.s_c.creg;
                                    s(sch_num).MC(sch_age) = mean(creg(Lc == cell_s));
                                %catch
                                end
                                %try
                                if sum(ismember(colors,'r'))
                                    %rreg = load([segdir D{segctr}],'rreg'); rreg = double(rreg(1).('rreg'));
                                    %rreg= s_int.s_c.rreg;
                                    %rreg =rreg_c(:,:,segctr);
                                    s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_s));
                                %catch
                                end
                                sch_num = sch_num - 1; %sch_num is now reset to the mother cell's main daughter
                                s(sch_num).approved =1;
                            end
                            s(1).sch_num=sch_num;
                            s(1).sch_age=sch_age;
        
                            %clear Lc Lc_c len r yreg yreg_c creg creg_c yreg yreg_c creg rreg;
                            %clear Lc  len r yreg  creg  yreg  creg rreg;
                            if save_no==1||segctr==do_frames_now(end)
                                for ctr = 1:length(s)
                                    if isempty(s(ctr).D); s(ctr).D = 0; end;
                                    if isempty(s(ctr).E); s(ctr).E = 0; end;
                                end
                                eval(['s_'  strrep(poslist{posctr},'-','_'), '_', str2(c), ' = s;']);
                                s(1).done=1;
                                all_data{c}=s;
                            else
                                all_data{c}=s;
                            end
                        end
                    end

                end
%                disp('Po');
        end
        clear Lc_m yreg_m reg_m rreg_m Lc_c yreg_c creg_c rreg_c;
        %clear segctr D ctr segdir p s;
    end
% end
all_s=whos('s_Bacillus*');
all_s={all_s.name};
data_D=dir([p.tracksDir,'Ba*']);
% save([imgdir,'Data\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});
save([p.tracksDir,strrep(poslist{posctr},'-','_'),'track',str2(length(data_D)),'.mat'],all_s{:});
clear(all_s{:})
clear all_s
%     catch
%          disp(['Problem ']);
%     end
end

%loading all files into memory
D=dir([p.dateDir,'Ba*']);

for i=do_pos_now
    D_bac=dir([p.dateDir,D(i).name,'\data\B*']);
    D_bac_name={D_bac.name};
    num=cellfun(@(a) str2num(a(end-5:end-4)), D_bac_name);
    [~,ind]=sort(num);
    load([p.dateDir,D(i).name,'\data\',D_bac(ind(end)).name]);
end

%saving_all_data
if ~exist([imgdir,'Data\Tracks'])
    mkdir([imgdir,'Data\Tracks']);
end
all_s=whos('s_Bacillus*');
all_s={all_s.name};
data_D=dir([imgdir,'Data\Tracks\all*']);
save([imgdir,'Data\Tracks\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});



% function tracking_main_low_memory()