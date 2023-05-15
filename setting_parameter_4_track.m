function do=setting_parameter_4_track(do)
%adding parameters to do

if do.chip==1
    do.buffer=100;
    do.buffer_crop=100;
else
    do.buffer=20;
    do.buffer_crop=20;
end
colors='ry';
do.colors=colors;