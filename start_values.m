function out = start_values(folder,area,resolution,massoffset)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
moleculelist=foldertolist(folder);
out=[repmat(area,1,length(moleculelist)) resolution massoffset];

end

