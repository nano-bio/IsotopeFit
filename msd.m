function out = msd(spec_measured,massaxis,shape,molecules,parameters)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%parameters: [area1, area2, area3...,resolution, massshift]

%out=sum((spec_measured-multispec(massaxis,molecules,parameters)).^2);

    
spec_calc=multispecparameters(massaxis,molecules,parameters,shape);
%out=sum((spec_measured-spec_calc).^2.*(spec_measured).^4);
out=double(sum((spec_measured-spec_calc).^2));
%out=sum((spec_measured-spec_calc).^2);
%out=sum(abs(spec_measured-spec));
    
end

