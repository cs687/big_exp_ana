function adding_time_stamp_to_data_PhsP19_2023_v3(inpath)
% function to correct for different times at which the image was taken
% The input is the p structure.
% in_path='\\slcu.cam.ac.uk\Data\Microscopy\teamjl\Chris\movies\2016-09-06\subAuto\';
% p = initschnitz('Bacillus-01','2018-05-11','bacillus','rootDir',in_path,'imageDir',in_path);
% f_start=1;
% f_end=30;
% wtf={'2019-09-06_correct_time'};

%Input parameter
% basename='sigV_w2RFP - Camera_s';
% p.rawDir=p.rootDir(1:end-8); % adding path do raw data
% p.dataDir=[p.rootDir,'data\'];


wavelength='w3';
%Checking input
if inpath(end)~='\'
    inpath=[inpath,'\'];
end


% Getting number of positions
D_cond=dir([inpath,'*',wavelength,'*s*_t1.tif']);
do_pos=length(D_cond)-1;

% Gettin number of timepoints
D_frames=dir([inpath,'*',wavelength,'*s1_t*.tif']);
do_tp=length(D_frames);

%Getting files names
f=strfind(D_cond(1).name ,'_');
movie_base=D_cond(1).name(1:f(2));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Getting Correct Time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist([inpath,'subAuto\Data\time_points_v1.mat']);
    % Getting number of positions
%     D_num_pos=dir([p.rootDir,'Bacillus-*p-001*']);
%     cand_pos=char({D_num_pos.name});
%     do_pos=str2num(cand_pos(:,10:11));
%     
%     D_num_tp=dir([p.rootDir,'Bacillus-',str2(1),'-p-*']);
%     cand_tp=char({D_num_tp.name});
%     do_tp=str2num(cand_tp(:,15:17));

    %Setting Memory
    time_mat=nan(max(do_tp),6,max(do_pos)); % time stamp in matrix: first coloumn: h, seceond column: min, third column: s 
    time_str=cell(max(do_tp),max(do_pos)); % time stamp as a string
    time_s=nan(max(do_tp),max(do_pos)); % time stamp in s; staring with the time of the day e.g. 17:39:22
    time_from_zero=nan(max(do_tp),max(do_pos)); % time starting at 0 for for the first timepoint in s
    delta_time_s=nan(max(do_tp)-1,max(do_pos)); % difference between time steps in s
    delta_time_min=nan(max(do_tp)-1,max(do_pos)); % difference between time steps in min


    % Adding time stamp to data
     for i=1:do_pos
%for i=1;
        % Gettin number of timepoints
%         D_num_tp=dir([p.rootDir,'Bacillus-',str2(i),'-p-*']);
% %         cand_tp=char({D_num_tp.name});
%         do_tp=str2num(cand_tp(:,15:17));

        disp(num2str(i/max(do_pos)));
        time_correction=0;
        abs_time_zero=0;
        for j=1:max(do_tp)
%for j=1:10
            %Getting Time stamp from image
            [time_mat(j,1:6,i),time_str{j,i}]=getting_timestamp_2023([inpath,movie_base,'s',num2str(i),'_t',num2str(j),'.tif']);

            %Getting fist time point, saving it and checking if there is a new
            %day
            if 1==j %getting start time
                  abs_time_zero=(time_mat(1,1,i)+time_correction)*3600+60*time_mat(1,2,i)+time_mat(1,3,i);
            elseif time_mat(j,4,i)~=time_mat(j-1,4,i) % checking if there is a new day
                time_correction=time_correction+24;
            end

            %converting time to seconds
            time_s(j,i)=(time_mat(j,1,i)+time_correction)*3600+60*time_mat(j,2,i)+time_mat(j,3,i);

            %getting time form zero
            time_from_zero(j,i)=(time_mat(j,1,i)+time_correction)*3600+60*time_mat(j,2,i)+time_mat(j,3,i)-...
                abs_time_zero;        
        end
        %calculating time difference
        delta_time_s(1:end,i)=diff(time_s(:,i));
        delta_time_min(1:end,i)=delta_time_s(1:end,i)./60;
    end

    %Saving time stamp
    save([inpath,'subAuto\Data\time_points_v1'],'time_mat','time_str','time_s','time_from_zero','delta_time_s','delta_time_min');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Add correct time to s structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist([p.dataDir,'all_files_all_tracked_corrected_data_correct_time_2020_1.mat']);
    load([p.dataDir,'time_points_v1']);
    %Loading corrected data into memory
    D=dir([p.dateDir,'Bacillus_*']);
    for i=1:length(D)
        if exist([p.dateDir,D(i).name,'\data\',D(i).name,'_lin_bak1.mat']);
            load([p.dateDir,D(i).name,'\data\',D(i).name,'-tracks']);
            %reducing size in memory by removing images
            s(1).Lc_c=[];
            s(2).Lc_c=[];
            s(3).Lc_c=[];
            s(1).yreg=[];
            s(1).rreg=[];
            if isfield(s,'preg');
                s(1).preg=[];
            end
            eval([D(i).name,'=s;']);
        end
    end

    D_corr=whos('Bacillus_*');

    % Adding time infromation to s
    corr_names=char({D_corr.name});
    corr_pos=num2str(corr_names(10:11));

    for i=1:length(D_corr)
        %load structure
        eval(['s=',D_corr(i).name,';']);
        %get pos of structure
        f=strfind(D_corr(i).name,'_');
        pos_ind=str2num(D_corr(i).name(f(1)+1:f(2)-1));
        %add time stamp
        for j=1:length(s)
            %adding time_s and time_zero
            %for k=1:length(s(j).frames);
                s(j).time_s=time_s(s(j).frames,pos_ind)';
                s(j).time_zero=time_from_zero(s(j).frames,pos_ind)';

            %end
            %adding delta
            if length(s(j).frames)>1
                if max(s(j).frames)<size(delta_time_s,1)
                    s(j).delta_min=delta_time_min(s(j).frames,pos_ind)';
                    s(j).delta_s=delta_time_s(s(j).frames,pos_ind)';
                else
                    s(j).delta_min=delta_time_min(s(j).frames(1:end-1),pos_ind)';
                    s(j).delta_s=delta_time_s(s(j).frames(1:end-1),pos_ind)';
                end
            else
                s(j).delta_min=nan;
                s(j).delta_s=nan;
            end
        end
        eval([D_corr(i).name,'=s;']);
    end

    pre={D_corr.name};
    save([p.dataDir,'all_files_all_tracked_corrected_data_correct_time_2020_1'],pre{:});
end

%concentrating_s_structure_to_matrix
%generatating_s_from_checked_v7_path(p,f_start,f_end,wtf);
%calc_s_magic_happening_2019_07_10_v1(p,wtf,f_start,f_end);







