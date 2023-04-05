% function channels=finding_channels_2022_02_10_v1(channels,Lc,i);
% % finds channels positions
% 
% [~,channels_cand]=findpeaks(sum(Lc),'MinPeakDistance',50);
% channels_cand2=channels_cand((channels_cand-20)>0&(channels_cand+20)<2048);
% channels(1:length(channels_cand2),i)=channels_cand2;


function [channels,stop_ana]=finding_channels_2022_02_10_v1(channels,Lc,i,do)
%function to find channels. 
stop_ana=0;
% finds channels positions
Lc=logical(Lc);
%find edge of channel from the top
f=find(sum(Lc,2)>mean(sum(Lc(1:end-300,:),2)));
%find peaks only in the first 200 pixels of the image
try
    if do.chip==0    
        [~,channels_cand]=findpeaks(sum(Lc(1:f(1)+200,:)),'MinPeakDistance',50);
    elseif do.chip==1
        [~,channels_cand]=findpeaks(sum(Lc),'MinPeakDistance',50);
    end
    channels_cand2=channels_cand((channels_cand-20)>0&(channels_cand+20)<2048);
    channels(1:length(channels_cand2),i)=channels_cand2;
catch
    stop_ana=1;
end
