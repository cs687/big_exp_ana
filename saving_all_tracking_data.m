function saving_all_tracking_data(p,do_pos_now)

%loading all files into memory
D=dir([p.dateDir,'Ba*']);

for i=do_pos_now
    D_bac=dir([p.dateDir,D(i).name,'\data\B*']);
    D_bac_name={D_bac.name};
    num=cellfun(@(a) str2num(a(end-5:end-4)), D_bac_name);
    [~,ind]=sort(num);
    if ~isempty(D)&&~isempty(D_bac)
        load([p.dateDir,D(i).name,'\data\',D_bac(ind(end)).name]);
    end
end

%saving_all_data
if ~exist([p.imageDir,'Data\Tracks'])
    mkdir([p.imageDir,'Data\Tracks']);
end
all_s=whos('s_Bacillus*');
all_s={all_s.name};
% data_D=dir([p.imageDir,'Data\Tracks\all*']);
% save([p.imageDir,'Data\Tracks\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});
data_D=dir([p.imageDir,'Data\all*']);
save([p.imageDir,'Data\','all_schnitz_',str2(length(data_D)),'m.mat'],all_s{:});
ind=calc_promo_21_11_01_BMM2(p);