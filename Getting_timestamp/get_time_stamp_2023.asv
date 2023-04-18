function get_time_stamp(inpath)

%Setting what to search for
% Normally YFP is in w3

wavelength='w3';

if inpath(end)~='\'
    inpath=[inpath,'\'];
end
%Finding number of conditions
D_cond=dir([inpath,'*',wavelength,'*s*_t1.tif']);
D_frames=dir([inpath,'*',wavelength,'*s1_t*.tif']);

f=strfind(D_cond(1).name ,'_');
movie_base=D_cond(1).name(1:f(2));
%wave_name=D(1).name(f(1)+1:f(2)-1);

for i=1:(length(D_cond)-1)
    for j=1:length(D_frames)
        imf=imfinfo([inpath,movie_base,'s',num2str(i),'_t',num2str(j),'.tif']);
        
    end
end
