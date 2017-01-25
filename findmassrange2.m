function out = findmassrange2(massaxis,molecules,resolution,massoffset,searchrange)
    com=calccomofmolecules(molecules);
    %guess sigma by calculating resolution at center of mass of molecules
    sigma=com/resolution*(1/(2*sqrt(2*log(2)))); 

    filter=zeros(size(massaxis,1),size(massaxis,2));
    for i=1:length(molecules)
        for j=1:size(molecules(i).peakdata,1)
            minmass=molecules(i).peakdata(j,1)+massoffset-searchrange*sigma;
            maxmass=molecules(i).peakdata(j,1)+massoffset+searchrange*sigma;
            filter=filter|(massaxis>=minmass&massaxis<=maxmass);
        end
    end

    out=find(filter==1);
end

