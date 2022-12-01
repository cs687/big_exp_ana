function [Lc_out,rreg_out,yreg_out,shift_hist,do_stop,varargout]=shift_x_2022_02_10_v1_speedy(Lc_m,rreg_m,yreg_m,preg_m,channels,do_now,do_phase,shift_hist,buffer_im);
do_stop=0;
f=find(channels(:,1)==0);

% for j=2:size(channels,2)
%     for i=1:f(end)-1
%         cand=nan(f(end)-1,1);
%         for k=1:f(end)-1
%             cand(k)=channels(k,j)-channels(i,j-1);
%         end
%         [~,ind]=min(abs(cand));
%         pre_shift(i,j-1)=cand(ind);
%     end
% end
%buffer_im=200;
buffer_x=buffer_im/2;

%pre_shift=channels(:,2:end)-channels(:,1:end-1);

% shift=round(cumsum(median(pre_shift(1:f(1)-1,:))));
Lc_out=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im);
%preg_out=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im,time_points);
yreg_out=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im);
rreg_out=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im);
if do_phase==1
    preg_out=zeros(size(Lc_m,1),size(Lc_m,2)+buffer_im);
end

size_x=size(Lc_m,2);

% for i=1:size(channels,2)
f2=find(channels(1,:)>0);
i=f2(end);
    if i==1
        Lc_out(:,buffer_x:buffer_x+size_x-1)=Lc_m;
       % preg_out(:,buffer_x:buffer_x+size_x-1,1)=preg_m(:,:,1);
        yreg_out(:,buffer_x:buffer_x+size_x-1)=yreg_m;
        rreg_out(:,buffer_x:buffer_x+size_x-1)=rreg_m;
        if do_phase==1
            preg_out(:,buffer_x:buffer_x+size_x-1)=preg_m;
        end
    else
        for z=1:f(end)-1
            cand=nan(f(end)-1,1);
            for k=1:f(end)-1
                cand(k)=channels(k,do_now)-channels(z,do_now-1);
            end
            [~,ind]=min(abs(cand));
            pre_shift(z,do_now-1)=cand(ind);
        end
        
        shift=round(cumsum(median(pre_shift(1:f(1)-1,:))));
        shift_hist(i)=shift(end);
       do_shift=sum(shift_hist);
       if abs(do_shift)>100
           do_stop=1;
       end
       Lc_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=Lc_m;
        rreg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=rreg_m;
        yreg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=yreg_m;
        if do_phase==1
            preg_out(:,buffer_x-do_shift:buffer_x+size_x-do_shift-1)=preg_m;
        end
       % preg_out(:,50-shift(i-1):50+size_x-shift(i-1)-1,i)=preg_m(:,:,i);
%        Lc_out(:,50-shift(i-1):50+size_x-shift(i-1)-1)=Lc_m;
%         rreg_out(:,50-shift(i-1):50+size_x-shift(i-1)-1)=rreg_m;
%         yreg_out(:,50-shift(i-1):50+size_x-shift(i-1)-1)=yreg_m;
%         if do_phase==1
%             preg_out(:,50-shift(i-1):50+size_x-shift(i-1)-1)=preg_m;
%         end
    end
%    figure;imshow(Lc_out);
if do_phase==1
    varargout{1}=preg_out;
end
% end

        

