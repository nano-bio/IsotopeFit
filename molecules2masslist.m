function [minmasslist,maxmasslist] = molecules2masslist(molecules)
%[minmasslist,maxmaslist] = molecules2masslist(molecules)
%   converts molecules structure to vectors with minimal and maximal masses
%   for every molecule

%strange! for your own mental health, do not try to understand this!
temp=[molecules{:}];
minmasslist=[temp.minmass];
maxmasslist=[temp.maxmass];


end

