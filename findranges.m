function ranges = findranges(molecules,calibration,searchrange)
%out = findranges(molecules)
%   finds mass-ovelapping molecules and orders them into ranges
%   output: out{rangenumber}.moleculese{moleculenumber}.[molecule structure]

if isempty(molecules)
    ranges=[];
else
    rangecount=1;
    ranges(1).minind=molecules(1).minind;
    ranges(1).maxind=molecules(1).maxind;
    ranges(1).minmass=molecules(1).minmass;
    ranges(1).maxmass=molecules(1).maxmass;
    ranges(1).molecules(1)=molecules(1);
    
    for i=2:length(molecules)
        %check if molecules overlap:
        mass_minus=searchrange*sigmabycalibration(calibration,molecules(i).com);
        mass_plus=searchrange*sigmabycalibration(calibration,molecules(i-1).com);
        if molecules(i).minmass-mass_minus<=ranges(rangecount).maxmass+mass_plus %molecule massrange ovelaps
            if ranges(rangecount).maxind<molecules(i).maxind
                ranges(rangecount).maxind=molecules(i).maxind;
                ranges(rangecount).maxmass=molecules(i).maxmass;
            end
            if ranges(rangecount).minind>molecules(i).minind
                ranges(rangecount).minind=molecules(i).minind;
                ranges(rangecount).minmass=molecules(i).minmass;
            end
            ranges(rangecount).molecules(end+1)=molecules(i);
        else %new massrange
            rangecount=rangecount+1;
            ranges(rangecount).minind=molecules(i).minind;
            ranges(rangecount).maxind=molecules(i).maxind;
            ranges(rangecount).minmass=molecules(i).minmass;
            ranges(rangecount).maxmass=molecules(i).maxmass;
            ranges(rangecount).molecules(1)=molecules(i);
        end
    end
       
    ranges=calccomofranges(ranges);
    
    for i=1:length(ranges)
        ranges(i).resolution=resolutionbycalibration(calibration,ranges(i).com);
        ranges(i).resolutionerror=NaN;
        ranges(i).massoffset=massoffsetbycalibration(calibration,ranges(i).com);
        ranges(i).massoffseterror=NaN;
    end
end

end

