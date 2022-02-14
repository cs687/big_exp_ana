function segpara_faster_par_nice_2021_05_25_v2(p,outprefix,regsize,SAVESEG,range)
%Function 

%input:
% p: p structure
% outprefix: 
% regsize,
% SAVESEG:
% range: vector with frames to segement

%Loop over all frames
for dude=1:length(range)
    i=range(dude);
    mynum = str3(i);
    Dframe = dir([p.imageDir p.movieName '*-t*-' str3(i) '.tif']);
    pname = Dframe(1).name;
    %reading rfp image into memory
    if p.numphaseslices==1
        X(:,:,1) = imread([p.imageDir,pname]);
    else
        fstr = findstr(pname,'-p-');
        for islice = 1:p.numphaseslices
            pname(fstr+3) = num2str(islice);
            X(:,:,islice) = imread([p.imageDir,pname]);
        end
    end
    %actual segementation
    [Lc,phsub,rect,s_end]= segfluor_Cs_2_faster_99(X, p);
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
    savelist=['''phsub'',''LNsub'',''Lc'',''tempsegcorrect'',''rect'',''timestamp'',''phaseFullSize'''];
    % nitzan 2005June25 added the following to save both phases if different:
    if p.segmentationPhaseSlice~=p.prettyPhaseSlice
        phseg = phsub(:,:,p.segmentationPhaseSlice);
        savelist = [savelist,',''phseg'''];
    end

    %Loading and resizing fluorecent images
    Lname= [outprefix,mynum];
    cname= [p.imageDir,p.movieName,'-c-',mynum,'.tif'];
    yname= [p.imageDir,p.movieName,'-y-',mynum,'.tif'];
    gname= [p.imageDir,p.movieName,'-g-',mynum,'.tif'];
    rname= [p.imageDir,p.movieName,'-t-',mynum,'.tif'];
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