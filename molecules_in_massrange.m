function out=molecules_in_massrange(molecules,minmass,maxmass)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

out=[];
for i=1:length(molecules)
    if is_molecule_in_massrange(molecules{i},minmass,maxmass)
        out=[out i];
    end
end

end

