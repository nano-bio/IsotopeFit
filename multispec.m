function out = multispec(molecules,resolution,massoffset,massaxis)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

spec_calc=zeros(1,length(massaxis));

for i=1:length(molecules)
    spec_calc=spec_calc+pattern(molecules{i},molecules{i}.area,resolution,massoffset,massaxis);
end

out=spec_calc;

end

