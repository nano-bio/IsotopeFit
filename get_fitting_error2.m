function errout = get_fitting_error(spec_measured,massaxis,molecule,molecules_involved,calibration)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

massoffset=0;
resolution=resolutionbycalibration(calibration,molecule.com); %resolution

spec_calc=multispecparameters(massaxis,molecule,[molecule.area,resolution,massoffset],calibration.shape)+multispec(molecules_involved,resolution,massoffset,massaxis,calibration.shape);

%minmsd=sqrt(double(sum((spec_measured-spec_calc).^2))/length(spec_measured));

minmsd=msd_area_variation(spec_measured,massaxis,molecules_involved,molecule,molecule.area,calibration);

errorlevel=0.1;

i=1;
msd1=0;
while (msd1<minmsd)&(i<=10)
    [msd1,spec1]=msd_area_variation(spec_measured,massaxis,molecules_involved,molecule,molecule.area*(1-i*0.2),calibration);
    i=i+1;
end
s1=(msd1^2-minmsd^2)/((molecule.area*(i-1)*0.2)^2); 
if (i==10)|(s1<0)
    errout(1)=NaN;
else
    errout(1)=errorlevel*minmsd/sqrt(s1);
end

i=1;
msd2=0;
while (msd2<minmsd)&(i<=10)
    [msd2,spec2]=msd_area_variation(spec_measured,massaxis,molecules_involved,molecule,molecule.area*(1+i*0.2),calibration);
    i=i+1;
end
s2=(msd2^2-minmsd^2)/((molecule.area*(i-1)*0.2)^2);
if (i==10)|(s2<0)
    errout(2)=NaN;
else
    errout(2)=errorlevel*minmsd/sqrt(s2)
end
       

end