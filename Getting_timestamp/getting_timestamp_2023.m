function [out_data,metadate]=getting_timestamp_2019_07_10(name_in)
% This function extractes the time stamp of an tiff image by using
% imfinfo('filename');
% This function only works on the raw data aquired with metamorph.
%
% Input: name_in; string with name of file e.g. 'sigV_w1Brightfield - Camera_s1_t1.tif'
% Output: out_date; vector e.g. [18,30,20,6,9,2016]; for an image aquired at 18h 30min 20s 6.9.2016;
% metadate: string e.g. '20160906 17:37:42'

im_info=imfinfo(name_in);
metadate=im_info.DateTime;

start_p=strfind(metadate,' ' );
intermediate_p=strfind(metadate,':');


out_data=zeros(1,6);
out_data(1)=str2num(metadate(start_p:intermediate_p(1)-1));%h
out_data(2)=str2num(metadate(intermediate_p(1)+1:intermediate_p(2)-1));%min
out_data(3)=str2num(metadate(intermediate_p(2)+1:end));%seconds
out_data(4)=str2num(metadate(7:8));%day
out_data(5)=str2num(metadate(5:6));%month
out_data(6)=str2num(metadate(1:4));%Year