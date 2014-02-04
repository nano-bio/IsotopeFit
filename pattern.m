function out = pattern(molecule,area,resolutionaxis,massshiftaxis,massaxis)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

y=zeros(1,length(massaxis));
peaksum=0;

%xc=[1,0.999890289,0.999522607];

xc=[0.00E+00,-1.55E-04,-6.74E-04];
w=[1.00,2.27,3.66];
A=[4.03E-01,4.57E-01,1.40E-01]; %fraction! sum has to be 1


for i=1:size(molecule.peakdata,1)
    %resolution=polynomial(resolutionpolynom,molecule.peakdata(i,1));
    %massshift=polynomial(massshiftpolynom,molecule.peakdata(i,1));
    
    sigma=molecule.peakdata(i,1)./resolutionaxis*(1/(2*sqrt(2*log(2)))); %factor:resolution in FWHM definition!!!!
    
%     for j=1:length(xc)%multiple peak fit
%         y=y+A(j)*area*molecule.peakdata(i,2)*(1./(sigma*w(j)*sqrt(2*pi))).*exp(-(1/2)*((massaxis-massshiftaxis-(sqrt(molecule.peakdata(i,1))+xc(j))^2)./(sigma*w(j))).^2); %Gauss
%         
%     end

    peaksum=peaksum+molecule.peakdata(i,2);
    
    eta=1; %1... Gauss --- 0... Lorentz
    y=y+eta*area*molecule.peakdata(i,2)*(1./(sigma*sqrt(2*pi))).*exp(-(1/2)*((massaxis-massshiftaxis-molecule.peakdata(i,1))./sigma).^2); %Gauss
    y=y+(1/pi)*(1-eta)*area*molecule.peakdata(i,2)*(sigma./(sigma.^2+(massaxis-massshiftaxis-molecule.peakdata(i,1)).^2)); %Lorentz
end
out=y/peaksum;
