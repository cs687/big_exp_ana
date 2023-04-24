function adding_time_stamp_to_data_Phs19_2023v1(inpath)
% function to correct for different times at which the image was taken
% The input is the p structure.


wavelength='w3';

if inpath(end)~='\'
    inpath=[inpath,'\'];
end




% Getting number of positions
D_cond=dir([inpath,'*',wavelength,'*s*_t1.tif']);
do_pos=length(D_cond);

% Gettin number of timepoints
D_frames=dir([inpath,'*',wavelength,'*s1_t*.tif']);
do_tp=length(D_frames);

%Getting files names
f=strfind(D_cond(1).name ,'_');
movie_base=D_cond(1).name(1:f(2));

%loading data into memory
%load([inpath,'\subAuto\Data\all_schnitz_500m.mat']);


%Input parameter
% basename='sigV_w2RFP - Camera_s';
% p.rawDir=p.rootDir(1:end-8); % adding path do raw data
% 
% % Loading corrected data into memory
% D=dir([p.dateDir,'Bacillus_*']);
% for i=1:length(D)
%     if exist([p.dateDir,D(i).name,'\data\',D(i).name,'_lin_bak1.mat']);
%         load([p.dateDir,D(i).name,'\data\',D(i).name,'-tracks']);
%         eval([D(i).name,'=s;']);
%     end
% end

% % Getting number of positions
% D_num_pos=dir([p.rootDir,'Bacillus-*p-001*']);
% cand_pos=char({D_num_pos.name});
% do_pos=str2num(cand_pos(:,10:11));
% 
% % Gettin number of timepoints
% D_num_tp=dir([p.rootDir,'Bacillus-01-p-*']);
% cand_tp=char({D_num_tp.name});
% do_tp=str2num(cand_tp(:,10:11));

%Setting Memory
time_mat=nan(max(do_tp),6,length(do_pos)); % time stamp in matrix: first coloumn: h, seceond column: min, third column: s 
time_str=cell(max(do_tp),length(do_pos)); % time stamp as a string
time_s=nan(max(do_tp),length(do_pos)); % time stamp in s; staring with the time of the day e.g. 17:39:22
time_from_zero=nan(max(do_tp),length(do_pos)); % time starting at 0 for for the first timepoint in s
delta_time=nan(max(do_tp)-1,length(do_pos)); % difference between time steps
% start_time_h=0;
% start_time_m=0;
% start_time_s=0;
time_correction=0;
abs_time_zero=0;

% Adding time stamp to data
%for i=1:do_pos
for i=1
    for j=1:max(do_tp)
        %Getting Time stamp from image
        %[time_mat(j,1:6,i),time_str]=getting_timestamp_2019_07_10([p.rawDir,basename,num2str(i),'_t',num2str(j),'.tif']);
        [time_mat(j,1:6,i),time_str]=getting_timestamp_2023([inpath,movie_base,'s',num2str(i),'_t',num2str(j),'.tif']);
        
        %Getting fist time point, saving it and checking if there is a new
        %day
        if i==1 %getting start time
%             start_time_h=time_mat(1,1,i);
%             start_time_m=time_mat(1,2,i);
%             start_time_s=time_mat(1,3,i);
              abs_time_zero=(time_out(1,1,i)+time_correction)*3600+60*time_out(1,2,i)+time_out(1,3,i);
        elseif time_mat(j,4,i)~=time_mat(j,4,i-1) % checking if there is a new day
            time_correction=time_correction+24;
        end
            
        %converting time to seconds
        time_s(j,i)=(time_out(j,1,i)+time_correction)*3600+60*time_out(j,2,i)+time_out(j,3,i);
        
        %getting time form zero
        time_from_zero(j,i)=(time_out(j,1,i)+time_correction)*3600+60*time_out(j,2,i)+time_out(j,3,i)-...
            abs_time_zero;        
    end
    delta_time(1:end,i)=diff(time_s(:,i));
end



figure; plot(delta_time);
%axis([0 100 580 640]);



