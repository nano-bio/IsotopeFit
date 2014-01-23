function out = calccomofmolecules(molecules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

areasum=0;
comtemp=0;

for j=1:length(molecules)
    areasum=areasum+molecules{j}.area;
    comtemp=comtemp+molecules{j}.com*molecules{j}.area;
end

if areasum==0
    comtemp=0;
    for j=1:length(molecules)
        comtemp=comtemp+molecules{j}.com;
    end
    out=comtemp/length(molecules);
else
    out=comtemp/areasum;
end

end

