function out=molecules_in_massrange_with_sigma(molecules,minmass,maxmass,calibration,searchrange)
%molecules_in_massrange_with_sigma checks if a molecule is in a certain
%massrange
%   gives back a list of molecules that are in the specfied massrange (=searchrange)

[minmasses, maxmasses]=molecules2masslist_with_sigma(molecules,calibration,searchrange);

inrange1=(minmasses>=minmass)&(minmasses<=maxmass); %Molecules with minmass in massrange
inrange2=(maxmasses>=minmass)&(maxmasses<=maxmass); %Molecules with maxmass in massrange
inrange3=(minmasses<=minmass)&(maxmasses>=maxmass); %Molecules that start before and end after massrange

out=find(inrange1|inrange2|inrange3)'; %convert boolean vector to indices

end

