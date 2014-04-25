function out = calccomofmolecules(molecules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

areasum=0;
comtemp=0;

areasum=sum([molecules.area]);
comtemp=sum([molecules.com].*[molecules.area]);

if areasum==0
    out=sum([molecules.com])/length(molecules);
else
    out=comtemp/areasum;
end

end

