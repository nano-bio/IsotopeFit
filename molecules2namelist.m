function namelist = molecules2namelist(molecules)
%[minmasslist,maxmaslist] = molecules2masslist(molecules)
%   converts molecules structure to cell array with molecule names

%strange! for your own mental health, do not try to understand this!
temp=[molecules{:}];
namelist={temp.name};


end

