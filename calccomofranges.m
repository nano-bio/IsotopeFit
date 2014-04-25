function out = calccomofranges(ranges)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(ranges)
    areasum=0;
    comtemp=0;
    arealist=[ranges(i).molecules.area];
    comlist=[ranges(i).molecules.com];
    areasum=sum(arealist);
    comtemp=sum(comlist.*arealist);
    
    if areasum==0
        for j=1:length(ranges(i).molecules)
            comtemp=comtemp+ranges(i).molecules(j).com;
        end
        ranges(i).com=comtemp/length(ranges(i).molecules);
    else
        ranges(i).com=comtemp/areasum;
    end
end

out=ranges;

end

