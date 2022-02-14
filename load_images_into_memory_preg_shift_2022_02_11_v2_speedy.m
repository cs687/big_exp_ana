function [Lc_m,rreg_m,yreg_m]=load_images_into_memory_preg_shift_2022_02_11_v2_speedy(p,pos_now,poslist,posctr,range)
% posctr=pos_now;
% range=1:800;
%Script to load all images into memory 
p_out = initschnitz(poslist{pos_now},'2021-11-03','bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);
p = initschnitz(poslist{pos_now},'2016-06-14','bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);


disp(poslist(posctr));

segdir = p.segmentationDir;
    
D = dir([segdir '*.mat']); 
D = {D.name};
if length(range)<2
    range_do=1:length(D);
elseif length(range)>length(D)
    range_do=1:length(D);
else
    range_do=range;
end

mat_zero_size=length(range_do);
D = dir([p.segmentationDir '*.mat']); 
D = {D.name};
    
    for im_ind=range_do
        Lc = load([segdir D{im_ind}],'Lc','yreg','rreg'); 
        L2= Lc(1).('Lc');
        Lc_m = L2;
        yreg_m=double(Lc(1).('yreg'));
        rreg_m=double(Lc(1).('rreg'));
        
        if im_ind==1
%              Lc = load([segdir D{im_ind}],'Lc');
%              L= Lc(im_ind).('Lc');
% %              L2 = bwlabel(L,4);
% %              Lc= L2;
%              im_s=size(Lc);
%               yreg = load([segdir D{im_ind}],'yreg');
% 
%               rreg = load([segdir D{im_ind}],'rreg');

            channels=zeros(100,max(range_do));
%             channels=finding_channels_2022_02_10_v1(channels,Lc,im_ind);
%             
%             Lc_m = L2;
%             yreg_m=double(yreg(1).('yreg'));
%             rreg_m=double(rreg(1).('rreg'));
             
        else
            %Add to Seg stack
%             Lc = load([segdir D{im_ind}],'Lc','yreg','rreg'); 
%             L2= Lc(1).('Lc');
%             Lc_m = L2;
%             yreg_m=double(Lc(1).('yreg'));
%             rreg_m=double(Lc(1).('rreg'));

%             channels=finding_channels_2022_02_10_v1(channels,Lc_m,im_ind);
%             [Lc,rreg,yreg]=shift_x_2022_02_10_v1_speedy(Lc_m,rreg_m,yreg_m,channels,im_ind);
%             save([p_out.segmentationDir,D{im_ind}],'Lc','yreg','rreg');
        end
            channels=finding_channels_2022_02_10_v1(channels,Lc_m,im_ind);
            [Lc,rreg,yreg]=shift_x_2022_02_10_v1_speedy(Lc_m,rreg_m,yreg_m,channels,im_ind);
            save([p_out.segmentationDir,D{im_ind}],'Lc','yreg','rreg');
    end
%     disp('aa');
    