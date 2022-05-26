function [Lc_m,rreg_m,yreg_m]=load_images_into_memory_preg_shift_2022_02_11_v2_speedy(p,pos_now,poslist,posctr,range,do_phase,date_in,date_out)
% posctr=pos_now;
% range=1:800;
%Script to load all images into memory 
p_out = initschnitz(poslist{pos_now},date_out,'bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);
p = initschnitz(poslist{pos_now},date_in,'bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);


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
        if do_phase==1
            preg_m=imread([p.rootDir,p.movieName,'-p-',str3(im_ind),'.tif']);
        elseif im_ind==range_do(1)
            preg_m=zeros(size(Lc));
        end
        L2= Lc(1).('Lc');
        Lc_m = L2;
        yreg_m=double(Lc(1).('yreg'));
        rreg_m=double(Lc(1).('rreg'));
        
        if im_ind==1
            Lc_mean=zeros(size(Lc_m,1),size(Lc_m,2)+100);
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
            if do_phase==1
                [Lc,rreg,yreg,preg]=shift_x_2022_02_10_v1_speedy(Lc_m,rreg_m,yreg_m,preg_m,channels,im_ind,do_phase);
            else
                [Lc,rreg,yreg]=shift_x_2022_02_10_v1_speedy(Lc_m,rreg_m,yreg_m,preg_m,channels,im_ind,do_phase);
            end 
            
            if do_phase==1
                save([p_out.segmentationDir,D{im_ind}],'Lc','yreg','rreg','preg');
            else
                save([p_out.segmentationDir,D{im_ind}],'Lc','yreg','rreg');
            end
            Lc_mean=Lc+Lc_mean;
    end   
 
% Making mean image with channels 
Lc_mean=Lc_mean/length(range_do);
figure; 
imshow(Lc_mean);
imwrite(Lc_mean,[p_out.movieDir,p.movieName,'_mean_image.tif']);
save([p_out.movieDir,p.movieName,'_Lcm.mat'],'Lc_mean');

%Finding channels
edge_line=sum(Lc_mean,2);
edge_cand=edge_line>max(edge_line)/2;
f=find(edge_cand);
[channels,mag]=peakfinder_2016(mean(Lc_mean(1:400,:)),0.3);
% if f(1)+200<size(Lc_mean,1);
%     [channels,mag]=peakfinder_2016(mean(mean(Lc_mean(1:f(1)+200,:,:),3)),0.3);
% else
%     [channels,mag]=peakfinder_2016(mean(mean(Lc_mean(end-200:end,:,:),3)),0.3);
% end

%Making sure that channels are far enough apart
bad_cand=find((channels(2:end)-channels(1:end-1))<40);

kill=nan(length(bad_cand),1);
if ~isempty(bad_cand)
    for i=1:length(bad_cand)
        if mag(bad_cand(i))>mag(bad_cand(i)+1)
            kill(i)=bad_cand(i)+1;
        else
            kill(i)=bad_cand(i);
        end
    end
    channels(kill)=[];
end

vline(channels,'r');
saveas(gcf,[p_out.movieDir,p.movieName,'_mean_image_with_channels.tif']);

%Saving channel pos
fid=fopen([p_out.movieDir,p.movieName,'_channels.txt'],'wt');
fprintf(fid, '%d\n', channels);
fclose(fid);
close(gcf);
    