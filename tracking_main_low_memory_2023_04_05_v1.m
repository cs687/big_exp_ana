function all_data=tracking_main_low_memory_2023_04_05_v1(p,do,all_data,Lc_m,rreg_m,yreg_m)
segctr=p.segctr;
p.continue=1;
channels=p.channels;
do_frames_now=p.segRange;


%looping over channels
for c=1:length(channels)
    %defining sturcutre for first frame
    if segctr == do_frames_now(1)
        %declare the s structure
        s = struct('frames',[],'P',[],'D',[],'E',[],'len',[],'wid',[],'MC',[],'MY',[],'MR',[],'cellno',[],'channel_pos',[]);
        sch_num = 1; 
        sch_age = 0;
        s.channel_pos=channels(c);
        s(1).segmentationDir = p.segmentationDir;
        s(1).movieName = p.movieName;
        s(1).done=0;
    else
        s=all_data{c};
        sch_num=s(1).sch_num;
        sch_age=s(1).sch_age;
    end

    %checking if this channel has terminated
    if s(1).done==0
        % cropping channel
        Lc=Lc_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);
        yreg=yreg_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);
        rreg=rreg_m(:,channels(c)-do.buffer_crop:channels(c)+do.buffer_crop);

        s(1).save_no=0;
        %resetting variables....why is this necessary?
        cell_m = -100;
        cell_s = -100;

        if sch_num==1
            s(sch_num).approved =1;
        end             
        %extract cell length & other properties
        r = regionprops(Lc,'MajorAxisLength','MinorAxisLength','Centroid');

        %find 'highest'/2nd 'highest' cell, in cell_m and cell_s(are indices to r and Lc)
        cens = vertcat(r.Centroid);
        if isempty(cens)==1
            break;
        end
        cenys = sort(cens(:,2));
        cell_m = find(cens(:,2) == cenys(1));

        try cell_s = find(cens(:,2) == cenys(2)); catch; end;
        if isempty(cell_s)==1
            if length(s)==1
                s(1).save_no=1;
            end
            break;
        end
        if cell_s<=0
            s(1).save_no=1;
            break;
        end
        clear cens cenys;       

        %debugging code
        %disp([cell_m cell_s]);
        %close all; myfig = figure; imshow(Lc,[]); impixelinfo; figure(myfig);
        %s;

        %check if cell has divided, remember we haven't updated sch_num and sch_age yet
        division_detected = 0;
        if sch_age > 1 
            if r(cell_m).MajorAxisLength < .75*s(sch_num).len(sch_age) %if it has divided                
                division_detected = 1;
            end
        end

        if division_detected == 1
            store_sch = sch_num;
            sch_num = length(s) + 1; %sch_num is now set to the sch of the new mother cell
            sch_age = 1;

            s(store_sch).D = sch_num;
            s(sch_num).P = store_sch;            
        else %if division event not detected
            sch_age = sch_age + 1;
        end

        % add various fields to s for mother cell                      
        s(sch_num).frames(sch_age) = segctr;                 
        s(sch_num).len(sch_age) = r(cell_m).MajorAxisLength;
        s(sch_num).wid(sch_age) = r(cell_m).MinorAxisLength;          
        s(sch_num).cellno(sch_age) = cell_m;
        s(sch_num).cenx(sch_age) = r(cell_m).Centroid(1);
        s(sch_num).ceny(sch_age) = r(cell_m).Centroid(2);

        % add fluorescence properties to s for mother cell, by first loading yreg,creg, for mother cell
        %try
        if sum(ismember(do.colors,'y'))
            %yreg = load([segdir D{segctr}],'yreg'); yreg = double(yreg(1).('yreg'));
            %yreg=yreg_c(:,:,segctr);
            %yreg= s_int.s_c.yreg;
            s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_m));
        end
        if sum(ismember(do.colors,'c'))
            %creg = load([segdir D{segctr}],'creg'); creg =
            %creg = creg_c(:,:,segctr);
            %creg= s_int.s_c.creg;
            s(sch_num).MC(sch_age) = mean(creg(Lc == cell_m));
        end
        if sum(ismember(do.colors,'r'))
            %rreg = load([segdir D{segctr}],'rreg'); rreg = double(rreg(1).('rreg'));
            %rreg =rreg_c(:,:,segctr);
            %rreg= s_int.s_c.rreg;
            s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_m));
        end

        % below is all code pertaining to the mother cell's other daughter
        if division_detected == 1        
            sch_num = length(s) + 1; %sch_num is now set to the lineage of the mother's other daughter
            s(sch_num).approved =1;
            s(sch_num).P = store_sch; %a bit confusing...
            s(store_sch).E = sch_num; %a bit confusing...
            s(sch_num).frames = segctr;            
            s(sch_num).len(sch_age) = r(cell_s).MajorAxisLength;
            s(sch_num).wid(sch_age) = r(cell_s).MinorAxisLength;  
            s(sch_num).cellno(sch_age) = cell_s;
            s(sch_num).cenx(sch_age) = r(cell_s).Centroid(1);
            s(sch_num).ceny(sch_age) = r(cell_s).Centroid(2);
            %try
            %if sum(ismember(colors,'y')) && mod(segctr+y_im_int-1,y_im_int)==0
                %yreg = load([segdir D{segctr}],'yreg'); yreg = double(yreg(1).('yreg'));

                %yreg=yreg_c(:,:,segctr); commented out 2022.02.11
                %yreg= s_int.s_c.yreg;
                s(sch_num).MY(sch_age) = mean(yreg(Lc == cell_s));
            %else
             %   s(sch_num).MY(sch_age)=0;
            %catch
           % end
            %try 
            if sum(ismember(do.colors,'c'))
                %creg = creg_c(:,:,segctr);
                %creg = load([segdir D{segctr}],'creg'); creg = double(creg(1).('creg'));
                %creg= s_int.s_c.creg;
                s(sch_num).MC(sch_age) = mean(creg(Lc == cell_s));
            %catch
            end
            %try
            if sum(ismember(do.colors,'r'))
                %rreg = load([segdir D{segctr}],'rreg'); rreg = double(rreg(1).('rreg'));
                %rreg= s_int.s_c.rreg;
                %rreg =rreg_c(:,:,segctr);
                s(sch_num).MR(sch_age) = mean(rreg(Lc == cell_s));
            %catch
            end
            sch_num = sch_num - 1; %sch_num is now reset to the mother cell's main daughter
            s(sch_num).approved =1;
        end
        s(1).sch_num=sch_num;
        s(1).sch_age=sch_age;

        %clear Lc Lc_c len r yreg yreg_c creg creg_c yreg yreg_c creg rreg;
        %clear Lc  len r yreg  creg  yreg  creg rreg;
%         if s(1).save_no==1||segctr==do_frames_now(end)
%             for ctr = 1:length(s)
%                 if isempty(s(ctr).D)
%                     s(ctr).D = 0; 
%                 end
%                 if isempty(s(ctr).E)
%                     s(ctr).E = 0;
%                 end
%             end
%             eval(['s_'  strrep(poslist{posctr},'-','_'), '_', str2(c), ' = s;']);
%             s(1).done=1;
%             all_data{c}=s;
%         else
%             all_data{c}=s;
%         end

        if s(1).save_no==1||segctr==do_frames_now(end)
            for ctr = 1:length(s)
                if isempty(s(ctr).D)
                    s(ctr).D = 0; 
                end
                if isempty(s(ctr).E)
                    s(ctr).E = 0;
                end
            end
            s(1).done=1;
            all_data{c}=s;
        else
            all_data{c}=s;
        end

    end
end
