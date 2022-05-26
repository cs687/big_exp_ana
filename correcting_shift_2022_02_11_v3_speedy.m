function correcting_shift_2022_02_11_v3_speedy(p,date_out_in,do)
%colors='ry';
do_phase=1;
savelist='''phsub'',''LNsub'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'',''yreg'',''yshift'',''yback'',''ybinning'',''rreg'',''rshift'',''rback'',''rbinning''';
poslist=get_poslist(p);
%poslist=poslist([1:6,8:end]);
D_all=dir([p.segmentationDir,'Bacillus-01-p-*']);
date_in=p.movieDate;
date_out=date_out_in;

%Checking if number pos to shift has been set
if isnan(do.pos)
    to_do_pos=1:length(poslist);
else
    to_do_pos=do.pos;
end

%checking if number of frames is set
if isnan(do.frames)
    to_do_frames=1:length(D_all);
else
    to_do_frames=do.frames;
end


%doing parallel computing only if needed
if do.para_shift==1
    parfor pos_now=to_do_pos
        disp(poslist{pos_now});
        load_images_into_memory_preg_shift_2022_02_11_v2_speedy(p,pos_now,poslist,pos_now,to_do_frames,do_phase,date_in,date_out);
    end
else
    for pos_now=to_do_pos
        disp(poslist{pos_now});
        load_images_into_memory_preg_shift_2022_02_11_v2_speedy(p,pos_now,poslist,pos_now,to_do_frames,do_phase,date_in,date_out);
    end
end
                
