function good_ind=calc_promo_21_11_01_BMM1(p)
%clear all
%load('all_schnitz_03m.mat');
%Variables:
% date1='2016-06-14';
% outpath='G:\2021-10-28\subAuto\Data\';
date1=p.movieDate;
outpath=p.dataDir;
D=dir([outpath,'\all_schnitz_*.mat']);
[~,ind]=sort(datenum({D.date}),'ascend');
load([outpath,D(ind(end)).name]);
%load([outpath,'\all_schnitz_02m.mat']);
% date1='2016-06-14';
good_ind=Renaming_Files_from_stg_2021_11_01_v1(p);
output_name=good_ind(:,1);

% output_name={'JLB254_SMM','JLB254_SMM_to_MPA',...
%             'JLB254_SMM_to_ETOH','JLB254_MPA+ETOH',...
%             'JLB254_MPA','JLB254_MPA_to_MPA+ETOH',...
%             'JLB254_ETOH_to_MPA+ETOH','JLB254_ETOH'};
%output_name={'JLB224_MPA','JLB224_EtoH','JLB224_MPA+EtoH','JLB224_EtoH'};
%output_name={'Ramp_0-1ug-ml-Lyso'};
%output_name={'3min'};
% first_pos={1,8,15,22,29,36,43,50};
% last_pos ={7,14,21,28,35,42,49,56};
%first_pos={1};
%last_pos={30};
first_pos=cellfun(@(a) a(1), good_ind(:,2),'UniformOutput',false);
last_pos=cellfun(@(a) a(end), good_ind(:,2),'UniformOutput',false);
im_int=10;
num_max_frames=1100;

all_c=whos('s_B*');

%textprogressbar('Calculating PromoterActivity: ')
num_cells=length(all_c);
for i=1:num_cells
    if length(eval(all_c(i).name))>1
        eval(['a_',all_c(i).name,'=','promoterActivity_final_bg_cs_GMM(',all_c(i).name,',0.05,200);']);
 %       textprogressbar(nearest(i*100/num_cells));
    end
end

all_c_name={all_c.name};
clear(all_c_name{:});


file_names=whos('a_s_Bac*');

names_cell={file_names.name};
fstr=strfind(names_cell{1},'_');
ind_val=cell2mat(cellfun(@(a) str2num(a(fstr(3)+1:end-3)),names_cell,'UniformOutput',false));

file_names_mat=char(names_cell);
% ind_val=str2num(file_names_mat(:,14:end-3));

% for ii = 1:length(file_names)
%     eval(['R.',file_names(ii).name,'=',file_names.name,';']);
% end

%for pp=1:2
for pp=1:length(first_pos)
    concentrate_schnitz_func_21_10_31_a_fixed_bug(first_pos{pp},last_pos{pp},ind_val, file_names_mat,output_name{pp},outpath,im_int,num_max_frames,date1)
    %textprogressbar(i);
end


