function out = pattern_conv_core(molecule,area,resolutionaxis,massshiftaxis,massaxis)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%peakshapes are stored as 4th order splines
global shape;
global shape_He;
%plot(convcore)

out=zeros(size(massaxis));

%this is not accurate! -> for large massranges, we need to calculate the
%resolution in the loop!!!
w=molecule.com/mean(resolutionaxis)/1.3;

% if strfind(molecule.name,'[He]')
%     peakshape=shape_He;
% else
%     peakshape=shape;
% end

peakshape=shape;

%sm=peakshape(:,1)'*w/2; %shape mass axis

% peak width adaption:
% shrink/strech x-points of spline
% and adapt coefficients accordingly
peakshape.breaks=peakshape.breaks*w/2;
peakshape.coefs=peakshape.coefs./((w/2).^repmat([3 2 1 0],size(peakshape.coefs,1),1));

if w<0 % make peakshape robust for negative resolution
    peakshape.breaks=peakshape.breaks(end:-1:1);
    peakshape.coefs=peakshape.coefs(end:-1:1,:);
end

% peak area adaption
% original peak has an area of 1.
% we need to restore this area after the change of the x-coordinates
peakshape.coefs=peakshape.coefs*2*area/w;
%s=peakshape(:,2)'*area/(w/2);%/(sum(peakshape(1:end-1,2)'.*diff(sm)));

for i=1:size(molecule.peakdata,1)
    evalspline=peakshape;
    evalspline.breaks=evalspline.breaks+molecule.peakdata(i,1);
    out=out+molecule.peakdata(i,2)*ppval(evalspline,massaxis-massshiftaxis);
    %out=out+interp1(sm+molecule.peakdata(i,1),s*molecule.peakdata(i,2),massaxis-massshiftaxis,'linear',0);
end

%int(out*dx)=area

%convolution:
