function [Lc_m,rreg_m,yreg_m]=load_images_into_memory_2018_04_04_v5(p,poslist,posctr,range)
%Script to load all images into memory 
%
%inputs:
%p: p structure
%postlist: cells array with name of positions to do
%posctr: current postion index to do
%range: vector with frames to track
%
%output:
%Lc_m: matrix with all segmentation mask
%rreg_m: matrix with all rfp images
%yreg_m: matrix with all yfp images

disp(poslist(posctr));

segdir = p.segmentationDir;
    
D = dir([segdir '*.mat']); 
D = {D.name};
%Checking if range is sensible
if length(range)<2
    range_do=1:length(D);
elseif length(range)>length(D)
    range_do=1:length(D);
else
    range_do=range;
end

%loading all images into memory
mat_zero_size=length(range_do);
for im_ind=range_do
    if im_ind==1
         Lc = load([segdir D{im_ind}],'Lc');
         L= Lc(im_ind).('Lc');

         %kill small objects
         props=regionprops(L,'Perimeter','Area');
         val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
         f=find(val<0.30);
         %f=find(val<0.25);
         L=ismember(L,f);
         L = bwlabel(L,4);

         %killing small cells
         r = regionprops(L,'Area');
         flittle = find([r.Area]>50);
         bw2 = ismember(L, flittle);
         L2 = bwlabel(bw2,4);

         Lc= L2;
         im_s=size(Lc);
         Lc_m=zeros([im_s,mat_zero_size]);
         Lc_m(:,:,im_ind)=Lc;
         %%%Loading yimages
         yreg_m=zeros([im_s,mat_zero_size]);
         yreg = load([segdir D{im_ind}],'yreg');
         yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
         %%%Loading rimages
         rreg_m=zeros([im_s,mat_zero_size]);
         rreg = load([segdir D{im_ind}],'rreg');
         rreg_m(:,:,im_ind)=double(rreg(1).('rreg'));
%              if sum(ismember(colors,'c'))
%                 creg_m=zeros([im_s,mat_zero_size]);
%                 creg = load([segdir D{im_ind}],'creg');
%                 creg_m(:,:,im_ind)=double(creg(1).('creg'));
%              end

    else
        %Add to Seg stack
        Lc = load([segdir D{im_ind}],'Lc'); 

        L= Lc(1).('Lc');

         %kill small objects
         props=regionprops(L,'Perimeter','Area');
         val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
         f=find(val<0.30);
         %f=find(val<0.25);
         L=ismember(L,f);
         L = bwlabel(L,4);

         %killing small cells
         r = regionprops(L,'Area');
         flittle = find([r.Area]>50);
         bw2 = ismember(L, flittle);
         L2 = bwlabel(bw2,4);

        Lc_m(:,:,im_ind) = L2;
        %Add to y stack
        yreg = load([segdir D{im_ind}],'yreg');
        yreg_m(:,:,im_ind)=double(yreg(1).('yreg'));
        %Add to r stack
        rreg = load([segdir D{im_ind}],'rreg');
        rreg_m(:,:,im_ind)=double(rreg(1).('rreg'));
        % Add to c stack
%             if sum(ismember(colors,'c'))
%                creg = load([segdir D{im_ind}],'creg');
%                creg_m(:,:,im_ind)=double(creg(1).('creg'));
%             end
    end
end
