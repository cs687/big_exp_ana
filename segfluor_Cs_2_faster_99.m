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
imt = imt - 2000;
e = edge(imt,'log',0);
f = imfill(e,'holes');
L = bwlabel(f);

%%%%%%%%%%%%%%%%%%%%%%%%%
%Schmutzkiller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
props=regionprops(L,'Perimeter','Area');
val=[props.Perimeter]./[props.Area]; %calculates ratio between surface area and the area of the segmented object
f=find(val<0.25);
L=ismember(L,f);
L = bwlabel(L,4);

%%%%%%%%%%%%%%%%%%%%%%%%
%killing small cells
%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Killing Schmutz by Area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Commented out 2022.03.23 Kills too much schmutz.
% props2=regionprops(L4,'Area','Perimeter');
% f3=find([props2.Area]>200&1500>[props2.Area]&[props2.Perimeter]./[props2.Area]<0.25);
% L5=bwlabel(ismember(L4,f3),4);
% L=L5;
L=L4;
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