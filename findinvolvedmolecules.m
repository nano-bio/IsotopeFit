function out = findinvolvedmolecules(molecules,searchlist,indices,searchrange,calibration)
%out = findinvolvedmolecules(molecules,index)
%   searches for molecules, that are within the massrange of molecule with
%   number [index]
%   only indices in searchlist are relevant. searchlist needs to be sorted!
%   output: list of indices

[minmasslist,maxmasslist]=molecules2masslist_with_sigma(molecules,calibration,searchrange);

%find consecutive indices
di_bool=diff(indices)~=1;
si=indices([true di_bool]); %start indices
ei=indices([di_bool true]); %end indices

%find massranges of partitions and molecules in this massrange
involved=indices;
for i=1:length(si)
    minmass=min(minmasslist(si(i):ei(i)));
    maxmass=max(maxmasslist(si(i):ei(i)));
    
    involved=union(involved,searchlist(molecules_in_massrange_with_sigma(molecules(searchlist),minmass,maxmass,calibration,searchrange)));
end

out=intersect(involved,searchlist);

end

