function write_startvalues(ranges,file)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fileID = fopen(file,'w');

for i=1:length(ranges)
    for j=1:length(ranges{i}.molecules)
        fprintf(fileID,'%e ',ranges{i}.molecules{j}.area);
    end
end

fprintf(fileID,'%e ',ranges{1}.resolution);
fprintf(fileID,'%e ',ranges{1}.massoffset);

fclose(fileID);


end

