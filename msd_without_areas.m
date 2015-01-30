function out = msd_without_areas(spec_measured,massaxis,shape,molecules,parameters)
%calculates areas by matrix division for given mu and sigma,
%parameters=[sigma,mu]
%returns msd to data
%parameters: [area1, area2, area3...,resolution, massshift]

%out=sum((spec_measured-multispec(massaxis,molecules,parameters)).^2);

paramin=[zeros(1,length(molecules)),parameters];
[parameters,~] = get_fit_params_using_linear_system(spec_measured,massaxis,shape,molecules,paramin,0,0);

spec_calc=multispecparameters(massaxis,molecules,parameters,shape);
%out=sum((spec_measured-spec_calc).^2.*(spec_measured).^4);
out=double(sum((spec_measured-spec_calc).^2));
%out=sum((spec_measured-spec_calc).^2);
%out=sum(abs(spec_measured-spec));
    
end

