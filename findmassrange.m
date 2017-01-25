function out = findmassrange(massaxis,molecules,resolution,massoffset,searchrange)
    %out = indices of mass range
    %   Calculates mass range displaying a certain range (factor*sigma) around
    %   the selected molecules. In case there is a mass offset it also shifts
    %   the spectrum accordingly.

    com=calccomofmolecules(molecules);
    sigma=com/resolution*(1/(2*sqrt(2*log(2)))); %guess sigma by center of mass of first molecule

    minmass=molecules(1).minmass+massoffset-searchrange*sigma;
    maxmass=molecules(end).maxmass+massoffset+searchrange*sigma;

    minind=mass2ind(massaxis,minmass);
    maxind=mass2ind(massaxis,maxmass);


    %out=massaxis>=minmass&massaxis<=maxmass;
    out=minind:maxind;
end

