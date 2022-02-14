function Crop_Frames_func_1_2021_11_22_v1(pos_do_now,dbs,cropBuff,image_folder,crop_folder, frames, w1, w2, out_name,chanwidth )
%This is the core functiont to prepare the images for segmentation. It
%rotates, crops, renames and save the images. It also detects the location
%of channels with cells.
% Inputs:
% pos_do_now: microscope position which is being prepared for segmentation
% dbs: Cell array with part of position name
% cropBuff: space in y direction between the end of the growth channel with cells inside
% image_folder: string with name of folder with images inside
% crop_folder: out folder name
% num_frames: Max number of frames to prepare
% w1: phase name 
% w2: rfp name
% out_name: name for output file e.g. 'Bacillus'
% chanwidth: channelwidth e.g. 24

disp(['Analysing Position: ',num2str(pos_do_now)]);

%1. Checking if roatation is needed on the phase image.
%The edge of the growth channels is brighter than the rest of the movie.
%Depending on its position in relation to the middle of the image a
% %decision is made on whether to roate the image or not. 
% phase_im=imread([dbs{1},w1,dbs{2},num2str(pos_do_now),dbs{3},'1','.tif']);
% phase_im_s=sum(phase_im,2);
% [x_p,~]=peakfinder_2016(phase_im_s);
% if x_p(1)>size(phase_im,1)
    rot_im=0;
% else
%     rot_im=1;
% end

%2. Averaging over all rfp images to get a better crop and channel
% %positions.
% average_im_sum = zeros(size(phase_im));
% movie_base_name=[dbs{1},w2,dbs{2},num2str(pos_do_now),dbs{3}];
% 
% disp('Start average of images');
% if length(frames)>120
%    max_average_im=120;
% else
%    max_average_im=frames(end);
% end
% 
% if length(frames)<50
%    start_average=1;
% else
%    start_average=20;
% end
% 
% for j = frames
%     im_rfp = imread([movie_base_name,num2str(j),'.tif']);
%     if rot_im==1
%         average_im_sum = (average_im_sum+double(imrotate(im_rfp,180)));
%     else
%         average_im_sum = (average_im_sum+double(im_rfp));
%     end
% end
% 
% average_im = average_im_sum/(max_average_im-start_average+1);


% %3. Find the channels in the vertical direction intensity trace (coardse
% %cropping)
% average_crop= mean(average_im ,2);
% %use simple threshold to find channels
% channel_cand = find(average_crop>mean(average_crop));
% %exclude edge pixels
% chan1 = min(channel_cand (channel_cand >100));
% chan2 = max(channel_cand (channel_cand <1948));
% %create new cropped image of channels
% average_im_crop = average_im(chan1-cropBuff:chan2+cropBuff,:); 
% 
% 
% 
% %4. Find the channels with cells
% average_im_crop_chan= mean(average_im_crop);
% [c_pos,~]=peakfinder_2016(average_im_crop_chan,100);
% 
% %discard first and last channels if they are too close to the edge (5 for
% %safety)
% if isempty(c_pos)
%     return;
% end
% 
% if c_pos(1)-chanwidth < 5
%     c_pos = c_pos(2:end);
% end
% if c_pos(end)+chanwidth > max(size(phase_im))-5
%     c_pos = c_pos(1:end-1);
% end
% 
% %5. Saving Channel Positions and Crop Mask
% cd([image_folder,crop_folder]);
% %Save Channel positions    
% fileID= fopen(['channel_pos_',str2(pos_do_now),'.txt'],'w');
% fprintf(fileID,'%d\n',c_pos);
% fclose(fileID);
% %Save Crop Mask     
% fileID= fopen(['crop_mask',str2(pos_do_now),'.txt'],'w');
% fprintf(fileID,'%d\n',[chan1,chan2]);
% fclose(fileID);
% 
% fclose('all');
% cd(image_folder);

%6. Cropping, roatating, renaming and saving images.
D=dir(['*_s',num2str(pos_do_now),'_t1.*']);
for j=1:length(D)
    ind_base_name=strfind(D(j).name,'t1.');
    base_name_loop=D(j).name(1:ind_base_name);
    ind=1;
    for k=frames
        pos_name=[base_name_loop,num2str(k),'.tif'];
        setpoints = findstr(pos_name,'_');  
        index_s_max=length(setpoints);
        if index_s_max==3
            name = pos_name(1:setpoints(1)-1);
        else
            name = pos_name((index_s_max-3):setpoints(index_s_max-2)-1);
        end
        channel = pos_name(setpoints(index_s_max-2)+1:setpoints(index_s_max-1)-1);
        stagepos = pos_name(setpoints(index_s_max-1)+2:setpoints(index_s_max)-1);
        timepoint = pos_name(setpoints(index_s_max)+2:end-4);
        if(findstr('RFP',channel))
            newchannel = 't'; %Fixed value
        else
            if(findstr('CFP',channel))
                newchannel = 'c';  %Fixed value
            else
                if(findstr('Brightfield',channel))
                    newchannel = 'p'; %Fixed value
                else
                    if(findstr('YFP',channel))
                        newchannel = 'y'; %Fixed value
                    end
                end
            end
        end

        newname = [out_name,'-',str2(str2num(stagepos)),'-',newchannel,'-',str3(ind),'.tif'];
        disp(newname);
        %Rotate and crop
%         if rot_im==1
%             im_rename=imrotate(imread(pos_name),180);
%             im_rename=im_rename(chan1-cropBuff:chan2+cropBuff,:);
%         else
            im_rename=imread(pos_name);
%         end
        disp(num2str(j));
        %Saving Image
        imwrite(im_rename,[image_folder,'\subAuto\',newname]);
        ind=ind+1;
    end
end