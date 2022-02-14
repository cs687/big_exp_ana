function channels=finding_channels_2022_02_10_v1(channels,Lc,i);
% finds channels positions

[~,channels_cand]=findpeaks(sum(Lc),'MinPeakDistance',50);
channels_cand2=channels_cand((channels_cand-20)>0&(channels_cand+20)<2048);
channels(1:length(channels_cand2),i)=channels_cand2;