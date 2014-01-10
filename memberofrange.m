function [out, rangeindex, moleculeindex] = memberofrange(ranges,rootindex)
%looks in ranges structure, molecule with index [index] is in one of this
%ranges

out=false;
rangeindex=-1;
moleculeindex=-1;



for i=1:length(ranges)
    for j=1:length(ranges{i}.molecules)
        if ranges{i}.molecules{j}.rootindex==rootindex
            out=true;
            rangeindex=i;
            moleculeindex=j;
        end
    end
end


end

