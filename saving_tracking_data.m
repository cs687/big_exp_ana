function saving_tracking_data(p,all_data)
%Loading data with name into memory
movie_name=[upper(p.movieKind(1)),p.movieKind(2:end),'_',p.movieName(end-2:end)];
for c=1:length(all_data)
    s=all_data{c};
    eval(['s_',  movie_name, '_', str2(c), ' = s;']);
end

all_s=whos('s_Bacillus*');
all_s={all_s.name};
data_D=dir([p.tracksDir,'Ba*']);
% save([imgdir,'Data\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});
save([p.tracksDir,movie_name,'track',str2(length(data_D)),'.mat'],all_s{:});
