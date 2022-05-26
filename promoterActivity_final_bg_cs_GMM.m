function snew = promoterActivity_final_bg_cs(s, gamma_fudge, back);
% function snew = promoterActivityPoly(s, gamma_fudge)
%
% 'promoterActivityPoly' calculates promoter activity for good fluorescent
% traces in the schnitz structure 's'. It returns a new schnitz structure
% 'snew' with additional fields for calculated data.
%
% %%%%% Parameters:
% gamma_fudge: bleaching/degradation constant (units of minutes)
%
%
% %%%%% New Fields Returned:
%
% len_smooth: smoothed cell length; used in promoter activity calculation.
% dlen_smooth: time derivative of len_smooth; used in promoter
% activity calculation.

% MX_smooth: smoothed version of mean cellular fluorescence X used in promoter
% activity calculation.
% dMX_smooth: time derivative of MX_smooth; used in promoter activity
% calculation.
%
% AX: calculated promoter activity of fluorescence trace X.
% AXlen: calculated promoter activity of fluorescence trace X normalized by
% cell length (a proxy for size).
%
% %%%%% Procedure:
%
% Derivation of promoter ('A') activity expression:
%
% dF/dt = A - \gamma * F
% F = M * V  (Total fluor = mean fluor * volume)
% dM/dt * V + dV/dt * M = A - \gamma * M * V
% V = L * W * H (length * width * height), dW/dt = dH/dt = 0
% dM/dt * L * W * H +  W * H * dL/dt * M = A - \gamma * M * L * W * H
% dM/dt * L + M * dL/dt = A - \gamma * M * L
% A = L * M * (dL/dt * 1/L + \gamma) + L * dM/dt
%
% Therefore to calculate A we need to calculate (1/L)*dL/dt and dM/dt
%
% - L is a direct observable.
% - dM/dt can be computed from M, preferably after smoothing.
% - (dL/dt)/L is the cellular growth rate, and can be computed directly from L
% - \gamma is protein degradation and also photobleaching. I will
% approximate it as zero for now, although photobleaching is undoubtedly
% *not* zero. We as gamma the input variable gamma_fudge. A value of 0.1
% seems to work well.
%
% Note that calculating these quantities across cell division events
% requires special care.

%Suppresses stupid messages about fitting
warning off;

% Input Processing
snew = s;

for j = 1 : length(s)

    frames = s(j).frames;
    if j==1
        Aframes= s(j).frames(2:end);
    else
        Aframes= s(j).frames;
    end
    
    
    len = s(j).len;
    %MC = s(j).MC;
    MY = s(j).MY -back;
    MR = s(j).MR;

    % If a schnitz has a parent, add a few frames of the parent to the
    % beginning of the length vector to increase quality of fit.
    P = s(j).P;




    appendedFramesParent = 0;
    if P > 0
        daughter = s(P).D;
        son = s(P).E;

        if ( (daughter > 0) & (son > 0) )
            lendaughter =   s(daughter).len(1);
            lenson =  s(son).len(1);
            if j == daughter
                ratio = lendaughter/(lendaughter +lenson);
            else
                ratio = lenson/(lendaughter+lenson);
            end
        else
            ratio = 0.5;
        end

        appendedFramesParent = 1; %min(3, length(s(P).frames));
        frames = [s(P).frames((end - appendedFramesParent + 1) : end) frames];
        len = [s(P).len((end - appendedFramesParent + 1) : end)*ratio len];
        %MC = [s(P).MC((end - appendedFramesParent + 1) : end) MC];
        MY = [s(P).MY((end - appendedFramesParent + 1) : end)-back MY];
        MR = [s(P).MR((end - appendedFramesParent + 1) : end) MR];
    else
        appendedFramesParent = 0;
    end

    % If schnitz has children, add total length of children to the end of
    % length vector to increase quality of fit.
    D1 = s(j).D;
    D2 = s(j).E;

    if ( (D1 > 0) & (D2 > 0) )
        if length(s)>=D1 && length(s)>=D2
            appendedFramesChildren = min([1 , length(s(D1).frames) , length(s(D2).frames)]);
            frames = [frames ( (frames(end)+1):(frames(end) + appendedFramesChildren) )];
            len = [len (s(D1).len(1 : appendedFramesChildren) + s(D2).len(1 : appendedFramesChildren))];
            %MC = [MC (s(D1).MC(1 : appendedFramesChildren) + s(D2).MC(1 : appendedFramesChildren))/2];
            MY = [MY (s(D1).MY(1 : appendedFramesChildren)-back + s(D2).MY(1 : appendedFramesChildren)-back)/2];
            MR = [MR (s(D1).MR(1 : appendedFramesChildren) + s(D2).MR(1 : appendedFramesChildren))/2];
        end
    else
        appendedFramesChildren = 0;
    end
    %CRAZY
    %     for d = length(len)-appendedFramesChildren:length(len)
    %     len(d) = (len(d)-len(d-1))/2 + len(d-1);
    %     end

    %     for d = length(len)-appendedFramesChildren:length(len)
    %     len(d) = len(d)+4;
    %     end
    % Store current effective schnitz length
    l = length(frames);

    % Smooth cell length. Note that 'smooth' returns a column vector. If
    % schnitz is too short, assign length vector to new smoothed length and
    % derivated of smoothed length quantities.
    if l > 5
        len_smooth = smooth(len,7,'lowess')';
        %len_smooth = smooth(len,20,'lowess')';
        %len_smooth=len;
    else
        len_smooth = len;
        polylen = len;
        dpolylen = len;
    end

    % Fit smoothed length to a 3rd order polynomial. The degree '3' was
    % chosen empirically.
    t = frames - frames(1); % zeroed time
    dt = (1/2) * (t(1 : (end-1)) + t(2 : end)); % midpoints of t
%     polycoeffs = polyfit(t, len_smooth, min(l,3));
%     dpolycoeffs = polyder(polycoeffs);
%     polylen = polyval(polycoeffs,dt);
%     dpolylen = polyval(dpolycoeffs,dt);
     dt = dt + frames(1); % midpoints of actual frames.
polylen = len_smooth;
dpolylen = diff(polylen);
 
    if  l >= 2
%MY_smooth = (MY);
        %MC_smooth = bfiltjoe(MC,5);
        MY_smooth = smooth(MY,5,'lowess')';
      
       % MY_smooth = bfiltjoe(MY,5);
        MR_smooth = smooth(MR,5,'lowess')';
        
        %dMC_smooth = diff(MC_smooth);
        dMY_smooth = diff(MY_smooth);
      %  dMY_smooth = smooth(dMY_smooth,'lowess')';
        dMR_smooth = diff(MR_smooth);
        
        % Currently the derivative of a length N signal has length N-1
        
        
%     elseif l == 2
%         MC_smooth = MC';
%         MY_smooth = MY';
%         MR_smooth = MR';
%         dMC_smooth = ones(1,2) * [MC(2) - MC(1)];
%         dMY_smooth = ones(1,2) * [MY(2) - MY(1)];
%         dMR_smooth = ones(1,2) * [MR(2) - MR(1)];
    else
        disp('Uh oh -- we have a SchnitzPhuk! This schnitz appears to have only 1 data point! Retrack?')
        disp('Values for this schnitz should be suspect!!!!!')
        %MC_smooth = MC';
        MY_smooth = MY';
        MR_smooth = MR';
        %dMC_smooth = MC(1);
        dMY_smooth = MY(1);
        dMR_smooth = MR(1);
    end
    
    
    
    % Begin Calculating Promoter Activity Quantities
% 
% 
%     if  l >= 3
% 
%         MC_smooth = bfiltjoe(MC,5);
%         MY_smooth = bfiltjoe(MY,5);
%         MR_smooth = bfiltjoe(MR,5);
%         %
%         %        MC_smooth = smooth(MC,ceil(l/3),'rlowess')';
%         %        MY_smooth = smooth(MY,ceil(l/3),'rlowess')';
%         %        MR_smooth = smooth(MR,ceil(l/3),'rlowess')';
% 
%         %        MC_smooth = MC;
%         %        MY_smooth = MY;
%         %        MR_smooth = MR;
% 
%         dMC_smooth = [MC_smooth(2) - MC_smooth(1)];
%         dMY_smooth = [MY_smooth(2) - MY_smooth(1)];
%         dMR_smooth = [MR_smooth(2) - MR_smooth(1)];
% 
%         for k = 3 : l
%             dMC_smooth = [dMC_smooth (MC_smooth(k) - MC_smooth(k-2))/2];
%             dMY_smooth = [dMY_smooth (MY_smooth(k) - MY_smooth(k-2))/2];
%             dMR_smooth = [dMR_smooth (MR_smooth(k) - MR_smooth(k-2))/2];
%         end
% 
%         dMC_smooth = [dMC_smooth (MC_smooth(l) - MC_smooth(l-1))];
%         dMY_smooth = [dMY_smooth (MY_smooth(l) - MY_smooth(l-1))];
%         dMR_smooth = [dMR_smooth (MR_smooth(l) - MR_smooth(l-1))];
% 
%         % Place dMX_smooth points at proper time points. Note that the first
%         % and last points are defined between frames. Now we average the
%         % remaining points to define them between frames. The proper number
%         % of points to extract are preserved.
% 
%         dMC_smooth = [dMC_smooth(1) (1/2)*(dMC_smooth(2:(end-2)) + dMC_smooth(3:(end-1))) dMC_smooth(end)];
%         dMY_smooth = [dMY_smooth(1) (1/2)*(dMY_smooth(2:(end-2)) + dMY_smooth(3:(end-1))) dMY_smooth(end)];
%         dMR_smooth = [dMR_smooth(1) (1/2)*(dMR_smooth(2:(end-2)) + dMR_smooth(3:(end-1))) dMR_smooth(end)];
%     elseif l == 2
%         MC_smooth = MC';
%         MY_smooth = MY';
%         MR_smooth = MR';
%         dMC_smooth = ones(1,2) * [MC(2) - MC(1)];
%         dMY_smooth = ones(1,2) * [MY(2) - MY(1)];
%         dMR_smooth = ones(1,2) * [MR(2) - MR(1)];
%     else
%         MC_smooth = MC';
%         MY_smooth = MY';
%         MR_smooth = MR';
%         dMC_smooth = MC(1);
%         dMY_smooth = MY(1);
%         dMR_smooth = MR(1);
%     end
  
  % 2010-10-04 We are attempting to fix end values of original code -
  % problem was it was skipping a frame between cell cycles. to fix this we
  % are keeping the last frame of the parent of the promoter activity trace.
 % appendedFramesChildren = 0;
  appendedFramesParent = 0;
    polylen = polylen((appendedFramesParent + 1) : (end - appendedFramesChildren));
    dpolylen = dpolylen((appendedFramesParent + 1) : (end - appendedFramesChildren));
    %MC_smooth = MC_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    MY_smooth = MY_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    MR_smooth = MR_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    %dMC_smooth = dMC_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    dMY_smooth = dMY_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    dMR_smooth = dMR_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    len_smooth = len_smooth((appendedFramesParent + 1) : (end - appendedFramesChildren));
    dt = dt((appendedFramesParent + 1) : (end - appendedFramesChildren));

   % Place MX_smooth at midpoints
    %MC_smooth = (1/2)* (MC_smooth(1 : (end-1)) + MC_smooth(2:end));
    MY_smooth = (1/2)* (MY_smooth(1 : (end-1)) + MY_smooth(2:end));
    MR_smooth = (1/2)* (MR_smooth(1 : (end-1)) + MR_smooth(2:end));
    %place Len_smooth at midpoints
        len_smooth = (1/2)* (len_smooth(1 : (end-1)) + len_smooth(2:end));
    polylen = len_smooth;

try
    mu = dpolylen ./ polylen;
catch
    dpolylen
    polylen
    len
    len_smooth
    MY
    MY_smooth
end
    %AC = polylen.*(dMC_smooth + MC_smooth.*(mu + gamma_fudge));
    AY = polylen.*(dMY_smooth + MY_smooth.*(mu + gamma_fudge));
    AR = polylen.*(dMR_smooth + MR_smooth.*(mu + gamma_fudge));
    AYlen = (dMY_smooth + MY_smooth.*(mu + gamma_fudge));
    %AClen = (dMC_smooth + MC_smooth.*(mu + gamma_fudge));
    ARlen = (dMR_smooth + MR_smooth.*(mu + gamma_fudge));

    snew(j).framesMid = dt;
    snew(j).polylen = polylen;
    snew(j).len_smooth = polylen;
    snew(j).dpolylen = dpolylen;
    snew(j).dlen_smooth = dpolylen;
    snew(j).MY_smooth = MY_smooth;
    %snew(j).MC_smooth = MC_smooth;
    snew(j).MR_smooth = MR_smooth;
    snew(j).dMY_smooth = dMY_smooth;
    %snew(j).dMC_smooth = dMC_smooth;
    snew(j).dMR_smooth = dMR_smooth;
    snew(j).mu = mu;
    %snew(j).AC = AC;
    snew(j).AY = AY;
    snew(j).AR = AR;
    snew(j).AYlen = AYlen;
    %snew(j).AClen = AClen;
    snew(j).ARlen = ARlen;
    snew(j).Aframes=Aframes;
    
end


% Further smooth promoter activities across cell cycles one last time.



