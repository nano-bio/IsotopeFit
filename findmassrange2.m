function out = findmassrange2(massaxis,molecules,resolution,massoffset,factor)

com=calccomofmolecules(molecules);
sigma=com/resolution*(1/(2*sqrt(2*log(2)))); %guess sigma by center of mass of first molecule

filter=zeros(size(massaxis,1),size(massaxis,2));
for i=1:length(molecules)
    for j=1:size(molecules{i}.peakdata,1)
        minmass=molecules{i}.peakdata(j,1)+massoffset-factor*sigma;
        maxmass=molecules{i}.peakdata(j,1)+massoffset+factor*sigma;
        filter=filter|(massaxis>=minmass&massaxis<=maxmass);
    end
end

out=find(filter==1);

end

