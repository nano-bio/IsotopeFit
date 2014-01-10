function out = multispecranges(massaxis,ranges)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

spec_calc=zeros(1,length(massaxis));

for i=1:length(ranges)
    nmolecules=length(ranges{i}.molecules);
    parameters=zeros(1,nmolecules+2);
    for j=1:length(ranges{i}.molecules);
        parameters(j)=ranges{i}.molecules{j}.area;
    end
    parameters(nmolecules+1)=ranges{i}.resolution;
    parameters(nmolecules+2)=ranges{i}.massoffset;
    
    spec_calc=spec_calc+multispec(massaxis, ranges{i}.molecules, parameters);
end

out=spec_calc;

end

