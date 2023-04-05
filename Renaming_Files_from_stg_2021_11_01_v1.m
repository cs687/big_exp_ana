function good_ind=Renaming_Files_from_stg_2021_11_01_v1(p)
%finds log file
f=strfind(p.rootDir,'\sub');
D=dir([p.rootDir(1:f(end)),'*.stg']);

%imports data
fileID = fopen([p.rootDir(1:f(end)),D(1).name]);
data=textscan(fileID,'%s %s %s %s %s %s %s %s %s %s %s %s %s','HeaderLines',4,'Delimiter',',');
posname=data{1}; % saving pads names

%number of pads =  length posname
pads=length(posname);
subwells=1;

%getting pad name
    for i=1:pads
        if posname{i}(end-1)=='1';
            r=strfind(posname{i},'_');
            namef{i}=posname{i}(2:r(length(r))-1);
        else
            namef{i}=posname{i}(2:end-1);
        end
    end
    namef_title=namef;
    for i=1:pads
        r=strfind(namef{i},'%');
        if length(r)>0
            namef{i}=[namef{i}(1:r(1)-1),namef{i}(r(1)+1:end)];
        end
    end
    for i=1:pads
        r=strfind(namef{i},'\');
        if length(r)>0
            namef{i}=[namef{i}(1:r(1)-1),namef{i}(r(1)+1:end)];
        end
    end
    for i=1:pads
        r=strfind(namef{i},'/');
        if length(r)>0
            namef{i}=[namef{i}(1:r(1)-1),namef{i}(r(1)+1:end)];
        end
    end

%removing Rest pos
keep_ind=cell2mat(cellfun(@(a) isempty(strfind(a,'Rest')),posname,'UniformOutput',false));
posname=posname(keep_ind);

% Removing number from name
clear pname;
num_ind=cellfun(@(a) strfind(a,'_'),posname,'UniformOutput',false);
for i=1:length(posname)-1
    pname{i}=posname{i}(2:num_ind{i}(end)-1);
end
pname=pname';
%unique names
name_unique=unique(pname);

%positions with name
for i=1:length(name_unique);
    good_ind{i,1}=name_unique{i};
    good_ind{i,2}=find(cell2mat(cellfun(@(a) strcmp(name_unique{i},a),pname,'UniformOutput',false))==1);
end
%disp('test');