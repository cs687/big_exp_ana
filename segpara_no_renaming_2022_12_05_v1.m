function segpara_no_renaming_2022_12_05_v1(p,outprefix,regsize,SAVESEG,frames_do_now)
%Function 

%input:
% p: p structure
% outprefix: 
% regsize,
% SAVESEG:
% range: vector with frames to segement

%Loop over all frames
% if isnan(p.do_frames)==1
%     frames_do_now=1:length(range);
% else
%     frames_do_now=p.do_frames;
% end
%     
for i=frames_do_now
    if p.do.rot==1
        mynum = str3(i);
        Dframe = dir([p.imageDir p.movieName '*-t*-' str3(i) '.tif']);
        pname = Dframe(1).name;
    else
        mynum = num2str(i);
        f=strfind(p.movieName,'-');
        base_name=([p.movieName(1:f(1)-1),'_']);
        pos_name=['_s',num2str(str2double(p.movieName(f(1)+1:end))),'_t',mynum,'.tif'];
        Dframe = dir([p.imageDir,base_name,p.do.rfp_name,pos_name]);
        pname = Dframe(1).name;
    end
    %reading rfp image into memory
     X(:,:,1) = imread([p.imageDir,pname]);

    %actual segementation
    [Lc,phsub,rect,s_end]= segfluor_Cs_2_faster_99(X, p);
    preg=phsub;
    phaseFullSize = size(Lc);
    
    %Stop if there has been a problem with the segmentation
    if s_end==1
        return;
    end
    
    if size(phsub,3)>1, % nitzan June25: this used to be: phsub = phsub(:,:,2);
        phsub = phsub(:,:,p.prettyPhaseSlice);
    end
    %Setting correction to 1.
    tempsegcorrect=1;
    LNsub=Lc;
    %savelist=['''phsub'',''LNsub'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'''];
    savelist=['''preg'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'''];
    % nitzan 2005June25 added the following to save both phases if different:
    if p.segmentationPhaseSlice~=p.prettyPhaseSlice
        phseg = phsub(:,:,p.segmentationPhaseSlice);
        savelist = [savelist,',''phseg'''];
    end

    %Loading and resizing fluorecent images
    Lname= [outprefix,mynum];
    if p.do.rot==1
        Lname= [outprefix,mynum];
        cname= [p.imageDir,p.movieName,'-c-',mynum,'.tif'];
        yname= [p.imageDir,p.movieName,'-y-',mynum,'.tif'];
        gname= [p.imageDir,p.movieName,'-g-',mynum,'.tif'];
        rname= [p.imageDir,p.movieName,'-t-',mynum,'.tif'];
    else
        Lname= [outprefix,str3(i)];
        cname=[p.imageDir,base_name,p.do.cfp_name,pos_name];
        yname=[p.imageDir,base_name,p.do.yfp_name,pos_name];
        gname=[p.imageDir,base_name,p.do.gfp_name,pos_name];
        rname=[p.imageDir,base_name,p.do.rfp_name,pos_name];
    end
    %CFP
    if exist(cname)==2
        [creg, cshift, cback, cbinning]= quicknoreg_v2(Lc,cname,rect,regsize,phaseFullSize);
        savelist=[savelist,',''creg'',''cshift'',''cback'',''cbinning'''];
    end
    %YFP
    if exist(yname)==2
        [yreg, yshift, yback, ybinning]= quicknoreg_v2(Lc,yname,rect,regsize,phaseFullSize);
        savelist=[savelist,',''yreg'',''yshift'',''yback'',''ybinning'''];
    end
    %GFP
    if exist(gname)==2
        [greg, gshift, gback, gbinning]= quicknoreg_v2(Lc,gname,rect,regsize,phaseFullSize);
        savelist=[savelist,',''greg'',''gshift'',''gback'',''gbinning'''];
    end
    %RFP
    if exist(rname)==2
        [rreg, rshift, rback, rbinning]= quicknoreg_v2(Lc,rname,rect,regsize,phaseFullSize);
        savelist=[savelist,',''rreg'',''rshift'',''rback'',''rbinning'''];
    end
    %Saving data
    timestamp = [];
    if SAVESEG
        eval(['save(''',p.segmentationDir,Lname,''',',savelist,');']);
        disp(['saved file ',p.segmentationDir,Lname]);
    end
end    