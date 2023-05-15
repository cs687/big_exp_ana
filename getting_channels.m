function channels=getting_channels(p,Lc_m,do)      
%Getting channel pos from first frame
edge_line=sum(Lc_m,2);
edge_cand=edge_line>max(edge_line)/2;
f=find(edge_cand);
Lc1=logical(Lc_m);
if f(1)+200<size(Lc_m,1)
    [~,channels]=findpeaks(mean(Lc1(1:f(1)+200,:,1)),'MinPeakDistance',do.buffer);
else
    [~,channels]=findpeaks(mean(Lc1(end-200:end,:,1)),'MinPeakDistance',do.buffer);
end
good_channels=channels>do.buffer_crop+1&channels<size(Lc1,2)-do.buffer_crop;
channels=channels(good_channels);
save([p.tracksDir,'channels.mat'],'channels');

%makeing control figure;
figure(100); 
imshow(Lc1);
vline(channels,'r');
set(gcf, 'InvertHardCopy', 'off');
a=size(Lc_m);
name_t=['Bacillus',p.movieName(end-3:end)];
text(a(2)*0.4,a(1)*0.05,name_t,'color','w','FontSize',20);
saveas(gcf,[p.tracksDir,'channel_crop.png']);
close(figure(100));
