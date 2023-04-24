function [indata,do_stop]=shift_x_seg_2022_12_07_v1_speedy(indata,do_now);
%This function does all the heavy lifting for the shift
indata.do_stop=0;

%Getting channel pos of first frame
f=isnan(indata.channels(:,1));

%buffer on each side of image
buffer_x=indata.buffer_im/2;

%image size
imsize_1=size(indata.Lc,1);
imsize_2=size(indata.Lc,2);
size_x=imsize_2;

%allocating memory for new image
Lc_out=zeros(imsize_1,imsize_2+indata.buffer_im);
yreg_out=zeros(imsize_1,imsize_2+indata.buffer_im);
rreg_out=zeros(imsize_1,imsize_2+indata.buffer_im);
preg_out=zeros(imsize_1,imsize_2+indata.buffer_im);



% finding last added channel and setting index to current
f2=~isnan(indata.channels(1,:));
i=f2(end);
%case if doing first position
if i==1
    Lc_out(:,buffer_x:buffer_x+size_x-1)=indata.Lc;
    yreg_out(:,buffer_x:buffer_x+size_x-1)=indata.yreg;
    rreg_out(:,buffer_x:buffer_x+size_x-1)=indata.rreg;
    preg_out(:,buffer_x:buffer_x+size_x-1)=indata.preg;
%all other cases
else
    %looping over all channels in first image (f(end)-1)
    for z=1:f(end)-1
        %allocating memory
        cand=nan(f(end)-1,1);
        %calculating the closes channel for each channel in the beginng
        for k=1:f(end)-1
            cand(k)=channels(k,do_now)-channels(z,do_now-1);
        end
        [~,ind]=min(abs(cand));
        pre_shift(z,do_now-1)=cand(ind);
    end
    
    %calculating median shift
    shift=round(cumsum(median(pre_shift(1:f(1)-1,:))));
    shift_hist(i)=shift(end);
    do_shift=sum(shift_hist);
    %if shift is to big stop
    if abs(do_shift)>100
        indata.do_stop=1;
    end
    %shifting data
    Lc_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=indata.Lc;
    rreg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=indata.rreg;
    yreg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=indata.yreg;
    preg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=indata.preg;
end
%redefine out data
indata.Lc=Lc_out;
indata.rreg=rreg_out;
indata.yreg=yreg_out;
indata.preg=preg_out;




        

