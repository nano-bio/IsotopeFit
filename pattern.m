function out = pattern(molecule,area,resolutionpolynom,massshiftpolynom,massaxis)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

y=zeros(1,length(massaxis));
peaksum=0;
for i=1:size(molecule.peakdata,1)
    resolution=polynomial(resolutionpolynom,molecule.peakdata(i,1));
    massshift=polynomial(massshiftpolynom,molecule.peakdata(i,1));
    sigma=molecule.peakdata(i,1)/resolution*(1/(2*sqrt(2*log(2)))); %factor:resolution in FWHM definition!!!!
    y=y+area*molecule.peakdata(i,2)*(1/(sigma*sqrt(2*pi)))*exp(-(1/2)*((massaxis-massshift-molecule.peakdata(i,1))/sigma).^2); %Gauss
    peaksum=peaksum+molecule.peakdata(i,2);
    %y=y+area*peakdata(i,2)*(1./(sigma*sqrt(2*pi)*(massaxis-massshift))).*exp(-(1/2)*((log(massaxis-massshift)-peakdata(i,1))/sigma).^2); %Lognormal
    %y=y+(1/pi)*area*peakdata(i,2)*(sigma./(sigma^2+(massaxis-massshift-peakdata(i,1)).^2)); %Lorentz
end
out=y/peaksum;
