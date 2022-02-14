function [xsubreg, xshift, xback, xbinning] = quicknoreg_v2(L, imx, rect, deltamax, fullsize)
% Function to resize images if needed
% Input
% L: segmented image
% imx: image file name which is being matched to the segmented image
% rect: transformation required to reconstruct full size image from smaller ones
% deltamax: max translation (pixels) between phase and fl. images 
% fullsize: size of L

% Output
% xsubreg: rescaled image
% xshift: shift of image
% xback: median value of image
% xbinning: image binning 

% load images if necessary
if min(size(imx))==1,
    if isempty(findstr('.tif', imx)),
        imx = [imx,'.tif'];
    end;
    if exist(imx)==2
        imx= imread(imx);
    end
end

sizeratio = fullsize./size(imx);
if sizeratio(1)==sizeratio(2) %& sizeratio(1)==round(sizeratio(1))
    if sizeratio(1)~=1
        disp(['fluor image is ',...
            num2str(sizeratio(1)),'x',num2str(sizeratio(1)),' binned.']);
        imx = imresize(imx,sizeratio(1),'nearest');
    end
    xbinning = sizeratio(1);
else
    disp('fluor image dimensions have different proportions than phase image.');
    error(' not equipped for such cases.');
end;


if min(size(imx))>1
    % get subimages
    imx1= double(imx(rect(1):rect(3), rect(2):rect(4)));
    LL= +(L(1+deltamax:end-deltamax, 1+deltamax:end-deltamax) > 0);
    % best translation is the one with largest csum (the most white pixels in LL)

    xshift= [0 0];

    xsubreg = imx(max(rect(1),1):min(rect(3),size(imx,1)),max(1,rect(2)):min(size(imx,2),rect(4)));
    % calculate background fluorescence
    imxb = double(imx);
    imxb(rect(1):rect(3), rect(2):rect(4))=0;
    imxbvect=imxb(imxb>0);
    xback=median(imxbvect);
else
    xsubreg=[];
    xshift=[];
    xback=[];
end;
