function cutcell= cell_breaker_streroids(cell, mincelllength)


%%%
%Segmenting on thin
%%%%%
% 1. Calc thin
% 2. Remove spurs
% 3. Find peaks peakfinder
% 4, Find trough peakfinder_min2


[fx, fy]= find(cell);
extra= 5;
xmin= max(min(fx) - extra, 1);
xmax= min(max(fx) + extra, size(cell,1));
ymin= max(min(fy) - extra, 1);
ymax= min(max(fy) + extra, size(cell,2));
subcell= cell(xmin:xmax, ymin:ymax);

%%%%%%%%%%%%%%%%%%%%%
% 1. Calc Thin
%%%%%%%%%%%%%%%%%%%%%
    thin= bwmorphmelow(subcell, 'thin', inf);


%%%%%%%%%%%%%%%%%%%%%
% 2. Remove Spurs
%%%%%%%%%%%%%%%%%%%%%
cline=bwmorph(thin,'spur',10);

im_e=imerode(subcell,strel('disk',3));
im_e_c=bwmorph(im_e,'spur');
connect=imdilate(cline-im_e_c.*cline,strel('disk',1));
cut=regionprops(logical(connect),'Centroid');

cutpts={cut.Centroid};


if ~isempty(cutpts)

        perim= bwperim(imdilate(subcell, strel('disk',1)));
       bsize= 8;
        for i= 1:length(cutpts)
            sxmin= max(1, cutpts{i}(2) - bsize);
            sxmax= min(size(perim,1), cutpts{i}(2)  + bsize);
            symin= max(1, cutpts{i}(1)  - bsize);
            symax= min(size(perim,2), cutpts{i}(1)  + bsize);
            subperim= perim(round(sxmin):round(sxmax), round(symin):round(symax));
            [subperim, noperims]= bwlabel(subperim);
            
            %cutx= cutpts{k}(1);
            %cuty= cutpts{k}(2);
%             bsize= 8;
%             sxmin= max(1, cutx(i) - bsize);
%             sxmax= min(size(perim,1), cutx(i) + bsize);
%             symin= max(1, cuty(i) - bsize);
%             symax= min(size(perim,2), cuty(i) + bsize);
%             subperim= perim(sxmin:sxmax, symin:symax);
%             [subperim, noperims]= bwlabel(subperim);

            % if noperims ~= 1  % JCR: noperims==0 causes problems below
            if noperims > 1
                
                % cutpt is not near end of cell. Go ahead and cut.
                currcell= subcell;
                [px, py]= find(subperim> 0);
                
                % find distances to perimeter from cutpt
                d= sqrt((px - bsize - 1).^2 + (py - bsize - 1).^2);
                [ds, di]= sort(d);
                
                % find first cutting point on perimeter
                cutperim1x= px(di(1)) + sxmin - 1;
                cutperim1y= py(di(1)) + symin - 1;
                colour1= subperim(px(di(1)), py(di(1)));
                
                % find second cutting point on perimeter
                colour= colour1;
                j= 2;
                while colour == colour1
                    colour= subperim(px(di(j)), py(di(j)));
                    j= j+1;
                end;
                cutperim2x= px(di(j-1)) + sxmin - 1;
                cutperim2y= py(di(j-1)) + symin - 1;
                
                % carry out cut 
                subcell= drawline(currcell, [cutperim1x(1) cutperim1y(1)],...
                    [cutperim2x(1) cutperim2y(1)], 0);
                %subcell= bwlabel(subcell, 4);
                
                % check cut
%                 rf= regionprops(subcell, 'majoraxislength');
%                 if min([rf.MajorAxisLength]) > mincelllength 
%                     % accept cut if it has not created too small cells
%                     currcell= subcell;
%                 else
%                     % ignore cut
%                     subcell= currcell;
%                 end;
                
             end;
        end;   
    else
        
        cutx= [];
        
 end;
    
%end;
            
cutcell= zeros(size(cell));
cutcell(xmin:xmax, ymin:ymax)= subcell;  