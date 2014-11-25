function [msd,specout] = msd_area_variation(spec_measured,massaxis,involved_molecules,molecule,area,calibration)

resolution=resolutionbycalibration(calibration,molecule.com);
massoffset=0;%massoffsetbycalibration(calibration,involved_molecules(moleculeindex).com);

paramin=[zeros(1,length(involved_molecules)),resolution,massoffset];

testspec=spec_measured-multispecparameters(massaxis,molecule,[area,resolution,massoffset]);

[parameters,~] = get_fit_params_using_linear_system(testspec,massaxis,involved_molecules,paramin,0,0);

spec_calc=multispecparameters(massaxis,molecule,[area,resolution,massoffset])+multispecparameters(massaxis,involved_molecules,parameters);
%plot(massaxis,spec_calc,massaxis,spec_measured);
%drawnow();
%pause(0.1);


%out=sum((spec_measured-spec_calc).^2.*(spec_measured).^4);
msd=double(sqrt(sum((spec_measured-spec_calc).^2)/length(spec_measured)));
%countsout=sum(spec_calc);
specout=spec_calc;
%out=sum((spec_measured-spec_calc).^2);
%out=sum(abs(spec_measured-spec));
    
end

