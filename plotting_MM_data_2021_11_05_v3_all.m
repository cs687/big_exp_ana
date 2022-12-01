function plotting_MM_data_2021_11_05_v3_all(p,what_plot)
% in_path='G:\2021-10-28\subAuto\Data\';
% D=dir([in_path,'JLB*']);
% D=dir([p.dataDir,'JLB*']);
% 
% figure;
% fig_para=fig_para_pres_func_v1;
% fig_para.gap_h=0.1;
% fig_para.margin_h=[0.05,0.025];
% set(gcf, 'Units', 'centimeters','PaperUnits', 'centimeters', 'PaperPosition',[0 0 19 25],'PaperSize', [19, 25], 'PaperType','A4',...
%     'Position',[15,3,19,25]);
% ha=tight_subplot_cs(4,2,0.08,0.1,fig_para.margin_h,[0.08,0.025]);
D=dir([p.dataDir,'JLB*']);

D=D([1,10,3,4,5,6,7,8,9,11,12,2]);

figure;
n_cond=length(D);
if mod(n_cond,2)==1
    cond_do=floor(n_cond/2)+1;
else
    cond_do=n_cond/2;
end


fig_para=fig_para_pres_func_v1;
fig_para.gap_h=0.1;
fig_para.margin_h=[0.05,0.025];
set(gcf, 'Units', 'centimeters','PaperUnits', 'centimeters', 'PaperPosition',[0 0 19 25],'PaperSize', [19, 25], 'PaperType','A4',...
    'Position',[15,3,19,25]);
ha=tight_subplot_cs(cond_do,2,0.08,0.1,fig_para.margin_h,[0.08,0.025]);


for i=1:length(D)
%ind=1;
%for i=[1,12,3,4,5,6,7,8,9,2,10,11]
%     load=([in_path,D(i).name]);
    load([p.dataDir,D(i).name]);
    if exist(what_plot,'var');
        %subplot(4,2,i);
        axes(ha(i));
        plot(eval(what_plot));
        xlabel('frames');
        ylabel(what_plot);
        a=axis;
        if strcmp(what_plot,'MY');
            axis([0, a(2), 0 10000]);
            %vline(37);
        elseif strcmp(what_plot,'AYlen');
            axis([0, a(2), 0 1000]);
            %vline(36.5);
        end
        title(strrep(D(i).name,'_',' '));
        a=axis;
        current_data=eval(what_plot);
        text(a(2)*0.7,a(4)*0.9,['n_{start}: ',num2str(sum(~isnan(current_data(1,:))))]);
        text(a(2)*0.7,a(4)*0.75,['n_{end}: ',num2str(sum(~isnan(current_data(388,:))))]);
        clear(what_plot);
    end
%     ind=ind+1;
end