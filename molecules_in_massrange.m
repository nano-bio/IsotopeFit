function out=molecules_in_massrange(masslist,minmass,maxmass)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

inrange1=(masslist.minmasses>=minmass)&(masslist.minmasses<=maxmass); %Molecules with minmass in massrange
inrange2=(masslist.maxmasses>=minmass)&(masslist.maxmasses<=maxmass); %Molecules with maxmass in massrange
inrange3=(masslist.minmasses<=minmass)&(masslist.maxmasses>=maxmass); %Molecules that start before and end after massrange

out=find(inrange1|inrange2|inrange3); %convert boolean vector to indices

% for i=1:length(molecules)
%     if is_molecule_in_massrange(molecules{i},minmass,maxmass)
%         out=[out i];
%     end
% end
end

