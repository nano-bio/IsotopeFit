function out = findinvolvedmolecules(molecules,searchlist,index,searchrange,calibration)
%out = findinvolvedmolecules(molecules,index)
%   searches for molecules, that are within the massrange of molecule with
%   number [index]
%   only indices in searchlist are relevant. searchlist needs to be sorted!
%   output: list of indices

minmass=molecules{min(index)}.minmass-searchrange*sigmabycalibration(calibration,molecules{min(index)}.com);
maxmass=molecules{max(index)}.maxmass+searchrange*sigmabycalibration(calibration,molecules{max(index)}.com);

massaxis=minmass:0.1:maxmass;
%massaxis=massaxis((massaxis>minmass)&(massaxis<maxmass));

filter=zeros(1,length(massaxis));
for i=index
    sigma=sigmabycalibration(calibration,molecules{i}.com);
    filter=filter|((massaxis<molecules{i}.maxmass+searchrange*sigma)&((massaxis>molecules{i}.minmass-searchrange*sigma)));
end

out=[];
%now look, if molecules in searchlist overlap
for i=setdiff(searchlist,index) %setdiff: dont look for index molecules again!
    sigma=sigmabycalibration(calibration,molecules{i}.com);
    
    minmass=molecules{i}.minmass-searchrange*sigma;
    maxmass=molecules{i}.maxmass+searchrange*sigma;
    
    %dont check molecules, that are far outside!
    if minmass>massaxis(end)
        break
    end
    
    if maxmass>massaxis(1)
        newfilter=((massaxis<maxmass)&((massaxis>minmass)));
        
        if any(newfilter&filter) %do indices overlap?
            filter=filter|newfilter;
            out=[out, i];
        end
    end
end

out=sort([out, index]);

end

