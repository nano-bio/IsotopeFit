function out = fitwithcalibration(molecules,peakdata,calibration,methode,deltam,deltar)

switch methode
    case 1
        ranges=findranges(molecules,0.3);
        
        for i=1:length(ranges)
            ranges{i}.resolution=resolutionbycalibration(calibration,ranges{i}.com);
            ranges{i}.massoffset=0;
        end
        
        ranges=fitranges(peakdata,ranges,Inf,deltar,deltam);
        
        k=1;
        for i=1:length(ranges)
            for j=1:length(ranges{i}.molecules)
                out(k)=ranges{i}.molecules(j);
                k=k+1;
            end
        end
    case 2
        out=fitmolecules(peakdata,molecules,calibration,Inf,deltar,deltam);
end

end

