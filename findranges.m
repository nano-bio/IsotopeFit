function ranges = findranges(molecules)
%out = findranges(molecules)
%   finds mass-ovelapping molecules and orders them into ranges
%   output: out{rangenumber}.moleculese{moleculenumber}.[molecule structure]

rangecount=1;
ranges{1}.minind=molecules{1}.minind;
ranges{1}.maxind=molecules{1}.maxind;
ranges{1}.minmass=molecules{1}.minmass;
ranges{1}.maxmass=molecules{1}.maxmass;
ranges{1}.molecules{1}=molecules{1};

for i=2:length(molecules)
    if molecules{i}.minmass<=ranges{rangecount}.maxmass %molecule massrange ovelaps
        ranges{rangecount}.maxind=molecules{i}.maxind;
        ranges{rangecount}.maxmass=molecules{i}.maxmass;
        ranges{rangecount}.molecules{end+1}=molecules{i};
    else %new massrange
        rangecount=rangecount+1;
        ranges{rangecount}.minind=molecules{i}.minind;
        ranges{rangecount}.maxind=molecules{i}.maxind;
        ranges{rangecount}.minmass=molecules{i}.minmass;
        ranges{rangecount}.maxmass=molecules{i}.maxmass;
        ranges{rangecount}.molecules{1}=molecules{i};
    end
end

ranges=calccomofranges(ranges);

end

