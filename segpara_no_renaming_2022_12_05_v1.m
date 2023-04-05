function segpara_no_renaming_2022_12_05_v1(p,outprefix,regsize,SAVESEG,frames_do_now,do)
% Function with core segmenation and some data extraction
% input:
% p: generated from initschnitz
% outprefix: name for saved output file
% regsize: sclar, max translation (pixels) between phase and fl
% SAVESEG: binar, whether to safe data or not 1=save, 0= not save
% frames_do_now: frames to segment (array)
% do: structure with information on how to segement
%


%Loop over all frames
% if isnan(p.do_frames)==1
%     frames_do_now=1:length(range);
% else
%     frames_do_now=p.do_frames;
% end
%     
for i=frames_do_now
    if i==1
        out.shift_hist=zeros(length(frames_do_now),1);
        out.channels=zeros(100,max(frames_do_now));
    end
    if p.do.rot==1
        mynum = str3(i);
        Dframe = dir([p.imageDir p.movieName '*-t*-' str3(i) '.tif']);
        pname = Dframe(1).name;
    else
        mynum = num2str(i);
        f=strfind(p.movieName,'-');
        base_name=([p.movieName(1:f(1)-1),'_']);
        pos_name=['_s',num2str(str2double(p.movieName(f(1)+1:end))),'_t',mynum,'.tif'];
        Dframe = dir([p.imageDir,base_name,p.do.rfp_name,pos_name]);
        pname = Dframe(1).name;
    end
    %reading rfp image into memory
     X(:,:,1) = imread([p.imageDir,pname]);

    %actual segementation
    [out.Lc,~,out.rect,s_end]= segfluor_Cs_2_faster_99(X, p);
%     out.preg=phsub;
%     out.Lc=Lc;
%     out.rect;
    
    out.phaseFullSize = size(out.Lc);
%     out.phaseFullSize;
    
    %Stop if there has been a problem with the segmentation
    if s_end==1
        return;
    end
    
%     if size(phsub,3)>1, % nitzan June25: this used to be: phsub = phsub(:,:,2);
%         phsub = phsub(:,:,p.prettyPhaseSlice);
%     end
    %Setting correction to 1.
    out.tempsegcorrect=1;
    out.timestamp=[];

    %%%%%%savelist=['''phsub'',''LNsub'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'''];
   % savelist=['''preg'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'''];
%     % nitzan 2005June25 added the following to save both phases if different:
%     if p.segmentationPhaseSlice~=p.prettyPhaseSlice
%         phseg = phsub(:,:,p.segmentationPhaseSlice);
%         savelist = [savelist,',''phseg'''];
%     end

    %Loading and resizing fluorecent images
    Lname= [outprefix,mynum];
    if p.do.rot==1
        Lname= [outprefix,mynum];
        cname= [p.imageDir,p.movieName,'-c-',mynum,'.tif'];
        yname= [p.imageDir,p.movieName,'-y-',mynum,'.tif'];
        gname= [p.imageDir,p.movieName,'-g-',mynum,'.tif'];
        rname= [p.imageDir,p.movieName,'-t-',mynum,'.tif'];
        pname= [p.imageDir,p.movieName,'-p-',mynum,'.tif'];
    else
        Lname= [outprefix,str3(i)];
        cname=[p.imageDir,base_name,p.do.cfp_name,pos_name];
        yname=[p.imageDir,base_name,p.do.yfp_name,pos_name];
        gname=[p.imageDir,base_name,p.do.gfp_name,pos_name];
        rname=[p.imageDir,base_name,p.do.rfp_name,pos_name];
        pname=[p.imageDir,base_name,p.do.phase_name,pos_name];
    end
    %CFP
    if exist(cname,'file')
        [out.creg, out.cshift, out.cback, out.cbinning]= quicknoreg_v2(out.Lc,cname,out.rect,regsize,out.phaseFullSize);
        %savelist=[savelist,',''creg'',''cshift'',''cback'',''cbinning'''];
    end
    %YFP
    if exist(yname,'file')
        [out.yreg, out.yshift, out.yback, out.ybinning]= quicknoreg_v2(out.Lc,yname,out.rect,regsize,out.phaseFullSize);
        %savelist=[savelist,',''yreg'',''yshift'',''yback'',''ybinning'''];
    end
    %GFP
    if exist(gname,'file')
        [out.greg, out.gshift, out.gback, out.gbinning]= quicknoreg_v2(out.Lc,gname,out.rect,regsize,out.phaseFullSize);
        %savelist=[savelist,',''greg'',''gshift'',''gback'',''gbinning'''];
    end
    %RFP
    if exist(rname,'file')
        [out.rreg, out.rshift, out.rback, out.rbinning]= quicknoreg_v2(out.Lc,rname,out.rect,regsize,out.phaseFullSize);
        %savelist=[savelist,',''rreg'',''rshift'',''rback'',''rbinning'''];
    end
    %Phase
    if exist(pname,'file')
        [out.preg, out.pshift, out.pback, out.pbinning]= quicknoreg_v2(out.Lc,pname,out.rect,regsize,out.phaseFullSize);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %shifting images if needed
    if do.shift==1
        [out2]=shift_data(i,out,do);
        if do.shift_show==1
            figure;
            imshow(out2.Lc);
            c_to_plot=out2.channels;
            c_to_plot(c_to_plot==0)=nan;
            vline(c_to_plot(:,i)+150,'r');
        end

        if out2.do_stop==1
            break;
        end
        if SAVESEG
            save([p.segmentationDir,Lname],'-struct','out2')
            disp(['saved file ',p.segmentationDir,Lname]);
        end
    else
        if do.shift_show==1
            figure;
            imshow(out.Lc);
%             c_to_plot=out2.channels;
%             c_to_plot(c_to_plot==0)=nan;
%             vline(c_to_plot(:,i)+150,'r');
        end
        if SAVESEG
            save([p.segmentationDir,Lname],'-struct','out')
            disp(['saved file ',p.segmentationDir,Lname]);
        end
    end
    
    %Saving data
%     timestamp = [];
%     if SAVESEG
%         eval(['save(''',p.segmentationDir,Lname,''',',savelist,');']);
%         disp(['saved file ',p.segmentationDir,Lname]);
%     end
end
end

function [out]=shift_data(im_ind,out,do);
out.buffer_im=300;

% if im_ind==1
%     Lc_mean=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im);
% %     out.channels=zeros(100,max(range_do));
% end
%finding channel pos
out.channels=finding_channels_2022_02_10_v1(out.channels,out.Lc,im_ind,do);

[out]=shift_x_seg_2022_12_07_v1_speedy(out,im_ind);
% 
% 
% 
%             Lc_mean=Lc+Lc_mean;
end   
 
% Making mean image with channels 
% Lc_mean=Lc_mean/length(range_do);

% figure; 
% imshow(Lc_mean);
% imwrite(Lc_mean,[p_out.movieDir,p.movieName,'_mean_image.tif']);
% save([p_out.movieDir,p.movieName,'_Lcm.mat'],'Lc_mean');
% 
% %Finding channels
% edge_line=sum(Lc_mean,2);
% edge_cand=edge_line>max(edge_line)/2;
% f=find(edge_cand);
% [channels,mag]=peakfinder_2016(mean(Lc_mean(1:400,:)),0.3);
% % if f(1)+200<size(Lc_mean,1);
% %     [channels,mag]=peakfinder_2016(mean(mean(Lc_mean(1:f(1)+200,:,:),3)),0.3);
% % else
% %     [channels,mag]=peakfinder_2016(mean(mean(Lc_mean(end-200:end,:,:),3)),0.3);
% % end
% 
% %Making sure that channels are far enough apart
% bad_cand=find((channels(2:end)-channels(1:end-1))<40);
% 
% kill=nan(length(bad_cand),1);
% if ~isempty(bad_cand)
%     for i=1:length(bad_cand)
%         if mag(bad_cand(i))>mag(bad_cand(i)+1)
%             kill(i)=bad_cand(i)+1;
%         else
%             kill(i)=bad_cand(i);
%         end
%     end
%     channels(kill)=[];
% end
% 
% vline(channels,'r');
% saveas(gcf,[p_out.movieDir,p.movieName,'_mean_image_with_channels.tif']);
% 
% %Saving channel pos
% fid=fopen([p_out.movieDir,p.movieName,'_channels.txt'],'wt');
% fprintf(fid, '%d\n', channels);
% fclose(fid);
% close(gcf);