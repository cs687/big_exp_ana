function [L, phsub, rect, s_end]= segfluor_Cs_2_faster_99(ph3, p)
% This is the core function which segments the images. Uses an edge detection
% algorithm to segments the cells. 
%   
%   Input:
%   ph3: rfp image to segment
%   p: p structure
%
%   Output: 
%   L:      segmented image 
%   phsub:  input rfp image)
%   rect:   transformation required to reconstruct full size image from smaller ones
%   s_end:  stop if no cells

buff_c=30;

%Checking for number of RFP images
if p.imNumber2>size(ph3,3)
    p.imNumber2 = 1;
end
if p.imNumber1>size(ph3,3)
    p.imNumber1 = size(ph3,3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparing RFP image to be segmented
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% median filter and rescale phase images
for i= 1:size(ph3,3)
    ph3(:,:,i)= medfilt2(ph3(:,:,i),[3 3]);
    x= double(ph3(:,:,i)-500);
    x(x<0)=0;
    s= sort(x(:));
    small= s(25);
    signal = s-(small+40);
    signal(signal<=0) = [];
    signal = signal+(small+40);
    if ~isempty(signal)
        big = signal(round(length(signal)*0.93));
        rescaled=(x - small)/(big - small);
        rescaled(rescaled<0)= 0;
        ph3(:,:,i)= uint16(10000*rescaled);
    else
        s_end=1;
        L=ph3;
    end
end
rect = [1 1 size(ph3,1) size(ph3,2)];
phsub = ph3(:,:,1);

%%%%%%%%%%%%%%%%%%
%Applying edge detection to segment image
%%%%%%%%%%%%%%%%%%
imt = phsub;
imt = imt - 2000;%2000

%caculating image characteristics
im_rounded=double(round(imt/100)*100);
im_median=median(im_rounded(:));
im_std=std(im_rounded(:));
imt2=imt;
% %killing schmutz in between channels
% peaks_c=peakfinder_2016(sum(imt,1));
% imt2=imt;
% for i=1:length(peaks_c)-1;
%     if (peaks_c(i+1)-buff_c)-(peaks_c(i)+buff_c)>0
%         imt2(:,peaks_c(i)+buff_c:peaks_c(i+1)-buff_c)=0;
%     end
% end
% if ~isempty(peaks_c)
%     if (peaks_c(1)-buff_c)>0
%        imt2(:,1:peaks_c(1)-buff_c)=0;
%     end
%     if peaks_c(end)+buff_c<size(imt,2)
%         imt2(:,peaks_c(end)+buff_c:end)=0;
%     end
% end




%segementation
e = edge(imt2,'log',0);
f = imfill(e,'holes');
L1 = bwlabel(f,4);
L=L1;

% if schmutz is an issue
if p.do_noise==1
    %First load phase image to get the edge of the channel
    pim=imread([p.rootDir,p.movieName,'-p-',str3(p.do_now),'.tif']);
    p_phase=peakfinder_2016(mean(pim,2));
    
    %removing cells from the bottom of the image
    if ~isempty(p_phase)%only if there is a peak
        L1(p_phase(1)+20:end,:)=0;
        imt2(p_phase(1)+20:end,:)=0;
        cand=[L1(p_phase(1)+19,:)'];
    else
        L1(end-10:end,:)=0;
        imt2(end-10:end,:)=0;
        cand=[cand;L1(end-9,:)'];
    end


    %Removing schmutz at the top of the image;
    f=find(mean(imt2,2)>mean2(imt2));
    c1=min(f(f>50));
    if ~isempty(c1)
        L1(1:c1-30,:)=0;
        imt2(1:c1-30,:)=0;
        cand=[cand;L1(c1-29,:)'];
        %cand=L1(c1-29,:)';
    else
        L1(1:10,:)=0;
        imt2(1:10,:)=0;
        cand=[cand;L1(11,:)'];
        %cand=L1(11,:)';
    end
    % %removing cells from the bottom
    % if c1+400<size(imt2,1)
    %    L1(c1+400:end,:)=0;
    %    cand=[cand;L1(c1+399,:)'];
    % else
    %     L1(end-10:end,:)=0;
    %     cand=[cand;L1(end-9,:)'];
    % end

    %killing schmutz in between channels
    %peaks_c=peakfinder_2016(sum(imt(1:size(imt,1)/2,:),1));
     [~,peaks_c]=findpeaks(mean(imt2,1),'MinPeakProminence',mean2(imt2));
    if ~isempty(peaks_c) %if peaks have been found
        for i=1:length(peaks_c)-1;%general case to remove are in between channels
            if (peaks_c(i+1)-buff_c)-(peaks_c(i)+buff_c)>0
                L1(:,peaks_c(i)+buff_c:peaks_c(i+1)-buff_c)=0;
                cand=[cand;L1(:,peaks_c(i)+buff_c-1);L1(:,peaks_c(i+1)-buff_c+1)];
            end
        end
        %Special case at the left edge
        if (peaks_c(1)-buff_c)>0
           L1(:,1:peaks_c(1)-buff_c)=0;
           cand=[cand;L1(:,peaks_c(1)-buff_c+1)];
        end
        %Special case at the right edge
        if peaks_c(end)+buff_c<size(imt,2)
            L1(:,peaks_c(end)+buff_c:end)=0;
            cand=[cand;L1(:,peaks_c(end)+buff_c-1)];
        end
    end
    %killing schmutz which touches the boarders.
    kill_cand=unique(cand);
    L=bwlabel(~ismember(L1,kill_cand),4);
end




% %%%%%%%%%%%%%%%%%%%%%%%%%
% %Schmutzkiller
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
props=regionprops(L,'Perimeter','Area');
val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
f=find(val<0.3); %0.3
L=ismember(L,f);
L = bwlabel(L,4);

% %%%%%%%%%%%%%%%%%%%%%%%%
% %killing small cells
% %%%%%%%%%%%%%%%%%%%%%%%%
r = regionprops(L,'Area');
flittle = find([r.Area]>50);
bw2 = ismember(L, flittle);
L2 = bwlabel(bw2,4);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BREAKING CELLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% break up big cells
% Goes along the THINned cell and looks for places where there is a change 
% in the phase value - i.e. where there could be a space between cells.
% uses PHSUB(:,:,p.imNumber1) (default p.imNumber1=2)
r= regionprops(L2, 'majoraxislength','ConvexArea');
fbiggies= find(([r.MajorAxisLength]>50|[r.ConvexArea]>1000));
Lcell=ismember(L2,fbiggies);
cutcell=cell_breaker_streroids(Lcell,p.minCellLength);
L3=logical(L2)-Lcell+logical(cutcell);
L4=bwlabel(L3,4);




% % 
% %%%%%%%%%%%%%%%%%%%%%%%%
% %killing small cells
% %%%%%%%%%%%%%%%%%%%%%%%%
r = regionprops(L4,'Area');
flittle = find([r.Area]>50);
bw2 = ismember(L4, flittle);
L5 = bwlabel(bw2,4);
L=L5;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Killing cellls by roughness
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r = regionprops(L5,'Perimeter','MajoraxisLength','MinoraxisLength');
% area_out=[r.Perimeter]./(2*pi*sqrt(([r.MajorAxisLength].^2+[r.MinorAxisLength].^2)./2));
% flittle2 = find([area_out]<=0.6);
% bw3 = ismember(L5, flittle2);
% L6 = bwlabel(bw3,4);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Schmutzkiller
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r = regionprops(L6,'Area','Perimeter');
% val=[r.Perimeter]./[r.Area]; %calculates ratio between surface area and the area of the segmented object
% f=find(val<0.3); %0.3
% bw4=ismember(L6,f);
% L7 = bwlabel(bw4,4);


%  L=L7;

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %Killing cells with weird axis ratio which hava low signal
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % r = regionprops(L7,'Area','Perimeter','MajoraxisLength','MinoraxisLength');
% % val=[r.MajorAxisLength]./[r.MinorAxisLength]; %calculates ratio between axis
% % f=find(val<3); %0.3
% % 
% % %Looping over candidates and killing if values is low
% % L8=L7;
% % for i=f
% %     pre=nan(size(L8));
% %     pre(L8==i)=1;
% %     cell_data=im_rounded.*pre;
% %     if nanmean(cell_data(:))<(im_median+ im_std*3)
% %         L8(L8==i)=0;
% %     end
% % end


% %%%%
% % Debugging
% %%%%%%%%%%
% % L_show(:,:,1)=L;
% % L_show(:,:,2)=L;
% % L_show(:,:,3)=L7;
% L_show(:,:,1)=mat2gray(imt);
% L_show(:,:,2)=mat2gray(imt);
% L_show(:,:,3)=L;
% % % figure;
% imshow(L_show);
% imshow(L7);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Final Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if max2(L)==0 % i.e. if there are no cells here...
    disp('Àoh no, there are no cells on this frame...?');
    s_end=1;
else
    s_end=0;
end
disp(['Total cells in this frame: ', num2str(max(max(L))),'.']);