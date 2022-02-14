function track_core_2019_06_13_v8m(p,Lc_m,yreg_m,rreg_m,channels,c,colors,poslist,posctr)
% Core function of tracking. First the images are cropped into the
% channels. Then the tracking starts. During the tracking the cells are
% matched based on their position in the channel. #1 stays number one etc.
% Division events are defined as a cell reducing its size by more than 25%.
%
%Inputs:
%p: p structure
%Lc_m: matrix with segmentation masks
%yreg_m: matrix with yfp images
%rreg_m: matrix with rfp images
%channels: growth channel positions
%c:index of current channel to do
%colors: colors to extract data from
%poslist: cell arrary with names of positions
%posctr: index of position

%Cropping out channels from stack
Lc_c=Lc_m(:,channels(c)-20:channels(c)+20,:);
yreg_c=yreg_m(:,channels(c)-20:channels(c)+20,:);
rreg_c=rreg_m(:,channels(c)-20:channels(c)+20,:);
%preg_c=preg_m(:,channels(c)-20:channels(c)+20,:);

s = struct('frames',[],'P',[],'D',[],'E',[],'ind_c',[],'len',[],'wid',[],'MC',[],'MY',[],'MR',[],'cellno',[],'channel_pos',[],'Lc_c',[],'yreg',[],'rreg',[]);
s.Lc_c=Lc_c;
s.yreg=yreg_c;
s.rreg=rreg_c;

%Tracking all frames
for segctr = 1:size(Lc_c,3)
    Lc=Lc_c(:,:,segctr);
    r = regionprops(Lc,'MajorAxisLength','MinorAxisLength','Centroid');

    % Get and sort y pos
    cens = vertcat(r.Centroid);
    %stop if no cells
    if isempty(cens)==1
        break;
    end
    
    %setting vector with y positions
    if length(cens)<20
        pad_cens=nan(20,1);
        pad_cens(1:length(cens(:,2)))=cens(:,2);
        [cenys, c_ind] =sort(pad_cens);
    else
        pad_cens=cens(:,2);
        [cenys, c_ind] =sort(cens(:,2));
    end
    
    %The first frame is special as it does not have a parent
    if segctr==1
        for cell_ind_t=1:sum([r.MajorAxisLength]>0)
            %adding data to schnitz structure
            cell_m=c_ind(cell_ind_t);
            sch_age=1;
            s(cell_ind_t).frames(sch_age) = segctr;
            s(cell_ind_t).P(sch_age) = 0;
            s(cell_ind_t).D(sch_age) = nan;
            s(cell_ind_t).E(sch_age) = nan;
            s(cell_ind_t).ind_c(sch_age) = cell_ind_t;
            s(cell_ind_t).len(sch_age) = r(cell_m).MajorAxisLength;
            s(cell_ind_t).wid(sch_age) = r(cell_m).MinorAxisLength;          
            s(cell_ind_t).cellno(sch_age) = cell_m;
            s(cell_ind_t).cenx(sch_age) = r(cell_m).Centroid(1);
            s(cell_ind_t).ceny(sch_age) = r(cell_m).Centroid(2);
            s(cell_ind_t).approved =1;
            % add fluorescence properties to s for mother cell, by first loading yreg,creg, for mother cell
            if sum(ismember(colors,'y'))
                yreg=yreg_c(:,:,segctr);
                s(cell_ind_t).MY(sch_age) = mean(yreg(Lc == cell_m));
            end
            if sum(ismember(colors,'c'))
                creg = creg_c(:,:,segctr);
                s(cell_ind_t).MC(sch_age) = mean(creg(Lc == cell_m));
            end
            if sum(ismember(colors,'r'))
                rreg =rreg_c(:,:,segctr);
                s(cell_ind_t).MR(sch_age) = mean(rreg(Lc == cell_m));
            end
        end
    else
        pre_ind=isnan([s.D]);
        open_s=find(pre_ind);
        cell_ind_t_old=cellfun(@(v) v(end), {s(open_s).ind_c});
        [val_old,ind_old]=sort(cell_ind_t_old);

        %for cell_ind_t=1:sum([r.MajorAxisLength]>0)
        cell_ind_t=1;

        for cell_ind_t_old=1:length(open_s)
            cell_m=c_ind(cell_ind_t);
            if isnan(cenys(cell_ind_t))
               sch_num=open_s(ind_old(cell_ind_t_old));
               store_sch=sch_num;
               s(store_sch).D = 0;
               s(store_sch).E = 0;
               s(store_sch).leave=1;
            else
                sch_age=length([s(open_s(ind_old(cell_ind_t_old))).frames]);
                sch_num=open_s(ind_old(cell_ind_t_old));
                division_detected = 0;
                if sch_age >= 1 
                    if r(cell_m).MajorAxisLength < .75*s(sch_num).len(sch_age) %if it has divided                
                        division_detected = 1;
                        %cell_ind_t=cell_ind_t+1;
                    end
                end
                try cell_s = c_ind(cell_ind_t+1); catch; end;

                if division_detected == 1
                    store_sch = sch_num;
                    sch_num = length(s) + 1; %sch_num is now set to the sch of the new mother cell
                    sch_age = 1;
                    s(store_sch).D = sch_num;
                    s(sch_num).P = store_sch;
                    s(sch_num).D = nan;
                    s(sch_num).E = nan;
                    cell_ind_t=cell_ind_t+2;
                else %if division event not detected
                    sch_age = sch_age + 1;
                    cell_ind_t=cell_ind_t+1;
                end

                % add various fields to s for mother cell    
                s(sch_num).frames(sch_age) = segctr;
                %s(sch_num).P(sch_age) = 0;
                %s(sch_num).D(sch_age) = nan;
                %s(sch_num).E(sch_age) = nan;
                if division_detected==1
                    s(sch_num).ind_c(sch_age) = cell_ind_t-1;
                else
                    s(sch_num).ind_c(sch_age) = cell_ind_t;
                end
                s(sch_num).ind_c(sch_age) = cell_ind_t;
                s(sch_num).len(sch_age) = r(cell_m).MajorAxisLength;
                s(sch_num).wid(sch_age) = r(cell_m).MinorAxisLength;          
                s(sch_num).cellno(sch_age) = cell_m;
                s(sch_num).cenx(sch_age) = r(cell_m).Centroid(1);
                s(sch_num).ceny(sch_age) = r(cell_m).Centroid(2);
                s(sch_num).approved =1;

                % add fluorescence properties to s for mother cell, by first loading yreg,creg, for mother cell
                %try
                if sum(ismember(colors,'y'))
                    yreg=yreg_c(:,:,segctr);
                    s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_m));
                end
                if sum(ismember(colors,'c'))
                    creg = creg_c(:,:,segctr);
                    s(sch_num).MC(sch_age) = mean(creg(Lc == cell_m));
                end
                if sum(ismember(colors,'r'))
                    rreg =rreg_c(:,:,segctr);
                    s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_m));
                end

                if division_detected == 1 && ~isnan(pad_cens(cell_s))
                %if division_detected == 1
                    sch_num = length(s) + 1; %sch_num is now set to the lineage of the mother's other daughter
                    s(sch_num).approved =1;
                    s(sch_num).P = store_sch; %a bit confusing...
                    s(sch_num).D = nan;
                    s(sch_num).E = nan;
                    s(sch_num).ind_c(sch_age) = cell_ind_t;
                    s(store_sch).E = sch_num; %a bit confusing...
                    s(sch_num).frames = segctr;            
                    s(sch_num).len(sch_age) = r(cell_s).MajorAxisLength;
                    s(sch_num).wid(sch_age) = r(cell_s).MinorAxisLength;  
                    s(sch_num).cellno(sch_age) = cell_s;
                    s(sch_num).cenx(sch_age) = r(cell_s).Centroid(1);
                    s(sch_num).ceny(sch_age) = r(cell_s).Centroid(2);
                    if sum(ismember(colors,'y'))
                        yreg=yreg_c(:,:,segctr);
                        s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_s));
                    end
                    if sum(ismember(colors,'c'))
                        creg = creg_c(:,:,segctr);
                        s(sch_num).MC(sch_age) = mean(creg(Lc == cell_s));
                    end
                    if sum(ismember(colors,'r'))
                        rreg =rreg_c(:,:,segctr);
                        s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_s));
                    end
                    %sch_num = sch_num - 1; %sch_num is now reset to the mother cell's main daughter
                    %s(sch_num).approved =1;
                end 
            end
        end
    end
end
%saving
mkdir([p.dateDir,strrep(poslist{posctr},'-','_'),'_', str2(c),'\data']);
save([p.dateDir,strrep(poslist{posctr},'-','_'),'_', str2(c),'\data\',strrep(poslist{posctr},'-','_'),'_', str2(c),'-tracks.mat'],'s');