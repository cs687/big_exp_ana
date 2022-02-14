function plotting_MM_data_2021_11_01_v3(p,what_plot)
% in_path='G:\2021-10-28\subAuto\Data\';
% D=dir([in_path,'JLB*']);
D=dir([p.dataDir,'JLB*']);

figure;
fig_para=fig_para_pres_func_v1;
fig_para.gap_h=0.1;
fig_para.margin_h=[0.05,0.025];
set(gcf, 'Units', 'centimeters','PaperUnits', 'centimeters', 'PaperPosition',[0 0 19 25],'PaperSize', [19, 25], 'PaperType','A4',...
    'Position',[15,3,19,25]);
ha=tight_subplot_cs(4,2,0.08,0.1,fig_para.margin_h,[0.08,0.025]);

for i=1:length(D)
%     load=([in_path,D(i).name]);
    load([p.dataDir,D(i).name]);
    if exist(what_plot,'var');
        %subplot(4,2,i);
        axes(ha(i));
        plot(eval(what_plot));
        xlabel('frames');
        ylabel(what_plot);
        a=axis;
        %axis([0, a(2), 0 4000]);
        axis([0, 110, 0 1000]);
        vline(36.5);
        title(strrep(D(i).name,'_',' '));
        clear MY
    end
end