function out = calccomofmolecules(molecules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

areasum=0;
comtemp=0;
for j=1:length(molecules)
    areasum=areasum+molecules{j}.area;
    comtemp=comtemp+molecules{j}.com*molecules{j}.area;
end
out=comtemp/areasum;

end

