function Finding_channels_and_rotate_2021_10_08_v3(in_path,do,varargin)
%1. This function automatically rotates the image to have the mother on the
% top of the channel. 
%2. It then crops the images to only contain the channels with cells in side. 
% On this image
% with all the loaded channel of this position the segmenation is
% performed in the next step. 
%3.Finally the location of the channel centers is stored in a text file. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input:
%The input stated below is optional. It is not required for the function to
%run
%'LastFrame': sets last frame to analyse.
%            e.g.Finding_channels_and_rotate_2021_05_25_v3('LastFrame',10);
%'PosList': defines the positions which will be analysed
%           e.g. Finding_channels_and_rotate_2021_05_25_v3('PosList',1:10);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Setting Parameters
edge_crop = 25; %distance between the middle of a channel and the edge of the crop
crop_folder='\subAuto'; %name of output put folder
w1='w1Phase'; %name of brightfield images
w2='w2RFP - Camera'; %name of RFP images
%w3='w3YFP - Camera'; %name of YFP images
out_name='Bacillus';
chanwidth=24;

%Making output folder
image_folder=in_path;

if ~exist([in_path,'subAuto'])
   mkdir([in_path,'subAuto']);
end



%Deleting Thumbfiles; This is specfic to data aquired with Metamorph
delete([in_path,'*_thumb_*']);
delete([in_path,'*[None]*']);

% Going through input
tf=0;
sp=0;
for i=1:2:length(varargin)-1
    switch varargin{i}
        case 'Frames'
            frames=varargin{i+1};
            tf=1;
        case 'LastFrame'
            num_frames=varargin{i+1};
            tf=1;
        case 'PosList'
            pos_to_do=varargin{i+1};
            sp=1;
        otherwise
            disp(['Help! You have made a spelling mistake in input ', num2str(i),'!']);
            return;
    end
end

%getting basename
base_name_pre=dir([in_path,'*w1Phase_s1_t1.tif']);
ind_base=strfind(base_name_pre(1).name,'_w1');
movie_base_name=base_name_pre(1).name(1:ind_base-1);

%getting total number of frames
if tf==0
    D=dir([in_path,'*w1Phase_s1_*']);
    frames=1:length(D);
end

%getting total number of yfp frames
D_num_frames_y=dir([in_path,'*w3YFP - Camera_s1_t*']);
num_frames_y=length(D_num_frames_y);

%getting number of stage positions
if sp==0
    D_stagepos=dir([in_path,'*w1Phase_s*_t1.tif']);
    stagepos=length(D_stagepos);  
    pos_to_do=1:stagepos-1;
end

%getting name parts
dummybase=([movie_base_name,'_*_s*_t*']);
dbs=strsplit(dummybase,'*');

if ~isnan(do.pos)
    pos_do_now=do.pos;
else
    pos_do_now=1:length(pos_to_do);
end

if ~isnan(do.frames)
    frames=do.frames;
end
% for do_now=1:length(pos_to_do)
for do_now=pos_do_now
    %Crop_Frames_func_1(pos_to_do(do_now),dbs,edge_crop,image_folder,crop_folder,num_frames, w1, w2,out_name,chanwidth )
    %try
        Crop_Frames_func_TI2_2022_11_11_v1(pos_to_do(do_now),dbs,edge_crop,image_folder,crop_folder,frames, w1, w2,out_name,chanwidth,in_path)
    %end
end      

