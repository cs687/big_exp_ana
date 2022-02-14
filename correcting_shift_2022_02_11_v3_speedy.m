function correcting_shift_2022_02_10_v2_speedy(p);
%colors='ry';
savelist='''phsub'',''LNsub'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'',''yreg'',''yshift'',''yback'',''ybinning'',''rreg'',''rshift'',''rback'',''rbinning''';
poslist=get_poslist(p);
D_all=dir([p.segmentationDir,'Bacillus-01-p-*']);
parfor pos_now=1:length(poslist);
%parfor pos_now=1:33;
%for pos_now=34
    disp(poslist{pos_now});
    %loading images
%     p_out = initschnitz(poslist{pos_now},'2021-11-03','bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);
%     p = initschnitz(poslist{pos_now},'2016-06-14','bacillus','rootDir',p.imageDir,'imageDir',p.imageDir);
    
  % try
  %     [Lc_m,rreg_m,yreg_m]=load_images_into_memory_preg_shift_2021_11_03_v1(p,poslist,pos_now,1:length(D_all));
       %[Lc_m,rreg_m,yreg_m]=load_images_into_memory_preg_shift_2021_11_03_v1_speed_func(p,poslist,pos_now,1:length(D_all));
%        [Lc_m,rreg_m,yreg_m]=load_images_into_memory_preg_shift_2022_02_10_v1_speedy(p,p_out,poslist,pos_now,1:length(D_all));
       %load_images_into_memory_preg_shift_2022_02_10_v1_speedy(p,p_out,poslist,pos_now,1:length(D_all));
       %load_images_into_memory_preg_shift_2022_02_10_v1_speedy(p,pos_now,poslist,pos_now,1:length(D_all));
       load_images_into_memory_preg_shift_2022_02_11_v2_speedy(p,pos_now,poslist,pos_now,1:length(D_all));
        %Shifting images
%         if exist('Lc_m')
%                 channels=zeros(100,size(Lc_m,3));
%                 for i=1:size(Lc_m,3);
%                     [~,channels_cand]=findpeaks(sum(Lc_m(:,:,i)),'MinPeakDistance',50);
%                     channels_cand2=channels_cand((channels_cand-20)>0&(channels_cand+20)<2048);
%                     channels(1:length(channels_cand2),i)=channels_cand2;
%                 end
%                 [Lc_out,rreg_out,yreg_out]=shift_x_2022_02_10_v1(Lc_m,rreg_m,yreg_m,channels);
%                 D = dir([p.segmentationDir '*.mat']); 
%                 D = {D.name};
%                 for i=1:size(Lc_out,3);
%                    % load([p.segmentationDir D{i}]);
%                     Lc=Lc_out(:,:,i);
%                     rreg=rreg_out(:,:,i);
%                     yreg=yreg_out(:,:,i);
%                     save([p_out.segmentationDir,D{i}],'Lc','yreg','rreg');
% %                     eval(['save(''',p_out.segmentationDir,D{i},''',',savelist,');']);
%                 end
%         end
  % end
end
%disp('aa');
                
