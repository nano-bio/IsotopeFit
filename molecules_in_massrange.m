function out=molecules_in_massrange(molecules,minmass,maxmass)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[minmasses, maxmasses]=molecules2masslist(molecules);

inrange1=(minmasses>=minmass)&(minmasses<=maxmass); %Molecules with minmass in massrange
inrange2=(maxmasses>=minmass)&(maxmasses<=maxmass); %Molecules with maxmass in massrange
inrange3=(minmasses<=minmass)&(maxmasses>=maxmass); %Molecules that start before and end after massrange

out=find(inrange1|inrange2|inrange3); %convert boolean vector to indices

end

