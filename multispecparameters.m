function out = multispecparameters(massaxis,molecules,parameters,shape)
%multispecparameters(massaxis,molecules,parameters)
%   calculates isotopic pattern for molecules in list
%   uses parameters for molecule areas, NOT area stored in molecules
%   structure
%   use this for fitting!
%parameters: [area1, area2, area3...,resolution, massshift]

%out=sum((spec_measured-multispec(massaxis,molecules,parameters)).^2);

spec_calc=zeros(1,length(massaxis));

for i=1:length(molecules)
    spec_calc=spec_calc+pattern_func(molecules(i),parameters(i),parameters(end-1),parameters(end),massaxis,shape);
end

%out=sum((spec_measured-spec).^2.*abs(spec_measured));
out=spec_calc;
%out=sum(abs(spec_measured-spec));
    
end


