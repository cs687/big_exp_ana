function concentrate_schnitz_func_21_10_31_a_fixed_bug(first_pos,last_pos,ind_val, file_names_mat,output_name,outpath,im_int,num_max_frames,date1)

s_size=size(file_names_mat);
%for ii = 1:length(file_names_mat)
for ii=1:s_size(1)
    C_ =  evalin('caller',[file_names_mat(ii,:) ';']);
    eval([file_names_mat(ii,:),'=C_;']);
end

ind=ind_val>=first_pos & ind_val<=last_pos;
out_n=num2cell(file_names_mat(ind,:),2);
file_names=out_n;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Def Matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frames=nan(num_max_frames,length(file_names));
MY=nan(num_max_frames,length(file_names));
MR=nan(num_max_frames,length(file_names));
wid=nan(num_max_frames,length(file_names));
len=nan(num_max_frames,length(file_names));
cenx=nan(num_max_frames,length(file_names));
ceny=nan(num_max_frames,length(file_names));
Len_at_dif=nan(num_max_frames,length(file_names));
MY_at_dif=nan(num_max_frames,length(file_names));
MR_at_dif=nan(num_max_frames,length(file_names));
frame_at_dif=nan(num_max_frames,length(file_names));
MR_at_start_cell=nan(num_max_frames,length(file_names));
Len_at_start_cell=nan(num_max_frames,length(file_names));
MY_at_start_cell=nan(num_max_frames,length(file_names));
frame_start_cell=nan(num_max_frames,length(file_names));
frame_mid_cell_cycle=nan(num_max_frames,length(file_names));
cell_cycle=nan(num_max_frames,length(file_names));
elong_rate=nan(num_max_frames,length(file_names));
frame_elong_rate=nan(num_max_frames,length(file_names));

framesMid=nan(num_max_frames,length(file_names));
polylen=nan(num_max_frames,length(file_names));
len_smooth=nan(num_max_frames,length(file_names));
dpolylen=nan(num_max_frames,length(file_names));
dlen_smooth=nan(num_max_frames,length(file_names));
MY_smooth=nan(num_max_frames,length(file_names));
MR_smooth=nan(num_max_frames,length(file_names));
dMY_smooth=nan(num_max_frames,length(file_names));
dMR_smooth=nan(num_max_frames,length(file_names));
mu=nan(num_max_frames,length(file_names));
AY=nan(num_max_frames,length(file_names));
AR=nan(num_max_frames,length(file_names));
AYlen=nan(num_max_frames,length(file_names));
ARlen=nan(num_max_frames,length(file_names));
Aframes=nan(num_max_frames,length(file_names));


for j=1:length(file_names)
    %a=eval(file_names(j).name);
    a=eval(file_names{j});
    af={a.frames};
    ac=struct2cell(a);
    f_names=fieldnames(a);
    kk=1;
    elong_rate_s=[];
    frame_er_s=[];
    for i=1:length(af)
        if length(af{i})==1
            a_ind(i)=false;
        else
            a_ind(i)=true;
            Len_at_dif(kk,j)=a(i).len(end);
            MY_at_dif(kk,j)=a(i).MY(end);
            MR_at_dif(kk,j)=a(i).MR(end);
            frame_at_dif(kk,j)=a(i).frames(end);
            MR_at_start_cell(kk,j)=a(i).MR(1);
            Len_at_start_cell(kk,j)=a(i).len(1);
            MY_at_start_cell(kk,j)=a(i).MY(1);
            frame_start_cell(kk,j)=a(i).frames(1);
            frame_mid_cell_cycle(kk,j)=a(i).frames(nearest(length(a(i).frames)/2));
            cell_cycle(kk,j)=length(a(i).frames);
            if i==1
                    for w=1:length(a(i).frames)-1;
                        er(w)=(a(i).len(w+1)-a(i).len(w))/im_int;
                        frame_er(w)=(a(i).frames(w+1)+a(i).frames(w))/2;
                    end
                    elong_rate_s=[elong_rate_s,er];
                    frame_er_s=[frame_er_s,frame_er];
                    clear er frame_er;
            elseif i==2
                er(1)=(a(i).len(1)+a(i+1).len(1)-a(i-1).len(end))/im_int;
                frame_er(1)=(a(i).frames(1)+a(i-1).frames(end))/2;
                for w=1:length(a(i).frames)-1;
                        er(w+1)=(a(i).len(w+1)-a(i).len(w))/im_int;
                        frame_er(w+1)=(a(i).frames(w+1)+a(i).frames(w))/2;
                end
                    elong_rate_s=[elong_rate_s,er];
                    frame_er_s=[frame_er_s,frame_er];
                    clear er frame_er;
            else
                er(1)=(a(i).len(1)+a(i+1).len(1)-a(i-2).len(end))/im_int;
                frame_er(1)=(a(i).frames(1)+a(i-2).frames(end))/2;
                for w=1:length(a(i).frames)-1;
                        er(w+1)=(a(i).len(w+1)-a(i).len(w))/im_int;
                        frame_er(w+1)=(a(i).frames(w+1)+a(i).frames(w))/2;
                end
                    elong_rate_s=[elong_rate_s,er];
                    frame_er_s=[frame_er_s,frame_er];
                    clear er frame_er;
            end

            kk=kk+1;

        end

    end
    a2=a(a_ind);
    a2_frames=[a2.frames];
    num_val=length(a2_frames);
    frames(1:num_val,j)=a2_frames;
    MY(1:num_val,j)=[a2.MY];
    MR(1:num_val,j)=[a2.MR];
    len(1:num_val,j)=[a2.len];
    wid(1:num_val,j)=[a2.wid];
    cenx(1:num_val,j)=[a2.cenx];
    ceny(1:num_val,j)=[a2.ceny];
    elong_rate(1:length(elong_rate_s),j)=elong_rate_s;
    frame_elong_rate(1:length(elong_rate_s),j)=frame_er_s;

    framesMid(1:num_val-1,j)=[a2.framesMid];
    polylen(1:num_val-1,j)=[a2.polylen];
    len_smooth(1:num_val-1,j)=[a2.len_smooth];
    dpolylen(1:num_val-1,j)=[a2.dpolylen];
    dlen_smooth(1:num_val-1,j)=[a2.dlen_smooth];
    MY_smooth(1:num_val-1,j)=[a2.MY_smooth];
    MR_smooth(1:num_val-1,j)=[a2.MR_smooth];
    dMY_smooth(1:num_val-1,j)=[a2.dMY_smooth];
    dMR_smooth(1:num_val-1,j)=[a2.dMR_smooth];
    mu(1:num_val-1,j)=[a2.mu];
    AY(1:num_val-1,j)=[a2.AY];
    AR(1:num_val-1,j)=[a2.AR];
    AYlen(1:num_val-1,j)=[a2.AYlen];
    ARlen(1:num_val-1,j)=[a2.ARlen];
    Aframes(1:num_val-1,j)=[a2.Aframes];


    clear a_ind kk elong_rate_s frame_er_s
end 
out=struct('MY',MY,'MR',MR,'len',len,'wid',wid,'cenx',cenx,'ceny',ceny, 'Len_at_dif',Len_at_dif,...
            'MY_at_dif',MY_at_dif, 'MR_at_dif', MR_at_dif, 'frame_at_dif', frame_at_dif, 'MR_at_start_cell',...
             MR_at_start_cell, 'Len_at_start_cell', Len_at_start_cell, 'MY_at_start_cell', MY_at_start_cell,...
             'frame_mid_cell_cycle',frame_mid_cell_cycle,'cell_cycle', cell_cycle,'elong_rate',elong_rate,...
             'frame_elong_rate',frame_elong_rate,'framesMid',framesMid,'polylen',polylen,'len_smooth',len_smooth,...
             'dpolylen',dpolylen,'dlen_smooth',dlen_smooth,'MY_smooth',MY_smooth,'MR_smooth',MR_smooth,....
             'dMY_smooth', dMY_smooth,'dMR_smooth',dMR_smooth,'mu',mu,'AY',AY,'AR',AR,'AYlen',AYlen,...
             'ARlen',ARlen,'Aframes', Aframes);
save([outpath,'\',output_name,'.mat'],'-struct','out');
