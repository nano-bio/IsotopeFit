function out = fitwithcalibration(molecules,peakdata,calibration,methode,searchrange,deltam,deltar,fitting_method)

switch methode
    case 1
        fprintf('Searching for ranges... ')
        ranges=findranges(molecules,calibration,searchrange);
        fprintf('done.\n')      
        
        ranges=fitranges(peakdata,ranges,calibration,Inf,deltar,deltam,fitting_method);
        
        k=1;
        
        fprintf('Saving areas to molecules structure... ')
        for i=1:length(ranges)
            for j=1:length(ranges(i).molecules)
                out(k)=ranges(i).molecules(j);
                k=k+1;
            end
        end
        fprintf('done.\n')
    case 2
        out=fitmolecules(peakdata,molecules,calibration,Inf,deltar,deltam,fitting_method);
end

end