function out = fitwithcalibration(molecules,peakdata,calibration)

ranges=findranges(molecules,0.3);

for i=1:length(ranges)
    ranges{i}.resolution=resolutionbycalibration(calibration,ranges{i}.com);
    ranges{i}.massoffset=0;
end

ranges=fitranges(peakdata,ranges,1e5,0,0.01);

k=1;
for i=1:length(ranges)
    for j=1:length(ranges{i}.molecules)
        out(k)=ranges{i}.molecules(j);
        k=k+1;
    end
end

end

