function out = multispec(molecules,resolutionaxis,massoffsetaxis,massaxis)
%out= multispec(molecules,resolution,massoffset,massaxis)
%   calculates isotopic pattern for molecules in list
%   uses area stored in molecules structure
%   DONT use this for fitting!
%parameters: [area1, area2, area3...,resolution, massshift]

spec_calc=zeros(1,length(massaxis));

for i=1:length(molecules)
    spec_calc=spec_calc+pattern(molecules{i},molecules{i}.area,resolutionaxis,massoffsetaxis,massaxis);
end

out=spec_calc;

end

