function out = pattern(molecule,area,resolutionaxis,massshiftaxis,massaxis,shape)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%peakshapes are stored as 4th order splines

%global shape_He;
%plot(convcore)

out=zeros(size(massaxis));

% this is not accurate! -> for large massranges, we need to calculate the
% resolution in the loop!!!
peakshape=peak_width_adaption(shape,molecule.com/mean(resolutionaxis),area);

for i=1:size(molecule.peakdata,1)
    if length(resolutionaxis)>1 %recalculate peakshape
        peakshape=peak_width_adaption(shape,molecule.com/resolutionaxis(mass2ind(massaxis,molecule.com)),area);
    end
    evalspline=peakshape;
    evalspline.breaks=evalspline.breaks+molecule.peakdata(i,1);
    out=out+molecule.peakdata(i,2)*ppval(evalspline,massaxis-massshiftaxis);
    %out=out+interp1(sm+molecule.peakdata(i,1),s*molecule.peakdata(i,2),massaxis-massshiftaxis,'linear',0);
end

%int(out*dx)=area

%convolution:
