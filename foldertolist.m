function out = foldertolist(folder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

a=dir(folder);
c=1;
for i=1:length(a)
    %if ~(strcmp(a(i).name,'.'))&&~(strcmp(a(i).name,'..'))&&~(strcmp(a(i).name,'Thumbs.db'))
    if ~isempty(strfind(a(i).name,'.txt'))
        out{c}=a(i).name;
        c=c+1;
    end
end

end

