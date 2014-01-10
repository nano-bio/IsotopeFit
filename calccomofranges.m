function out = calccomofranges(ranges)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(ranges)
    areasum=0;
    comtemp=0;
    for j=1:length(ranges{i}.molecules)
        areasum=areasum+ranges{i}.molecules{j}.area;
        comtemp=comtemp+ranges{i}.molecules{j}.com*ranges{i}.molecules{j}.area;
    end
    ranges{i}.com=comtemp/areasum;
end

out=ranges;

end

