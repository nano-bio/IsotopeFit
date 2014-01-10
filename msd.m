function out = msd(spec_measured,massaxis,molecules,parameters)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%parameters: [area1, area2, area3...,resolution, massshift]

%out=sum((spec_measured-multispec(massaxis,molecules,parameters)).^2);
spec=multispec(massaxis,molecules,parameters);
%out=sum((spec_measured-spec).^2.*abs(spec_measured));
out=sum((spec_measured-spec).^2);
%out=sum(abs(spec_measured-spec));
    
end

