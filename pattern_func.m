function out = pattern_func(molecule,area,resolutionaxis,massshiftaxis,massaxis,shape)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%peakshapes are stored as 4th order splines

%global shape_He;
%plot(convcore)

out=sparse(1,size(massaxis,2));

% this is not accurate! -> for large massranges, we need to calculate the
% resolution in the loop!!!
peakshape=peak_width_adaption(shape,molecule.com/mean(resolutionaxis),area);

massaxis=massaxis-massshiftaxis;
l=length(massaxis);
for i=1:size(molecule.peakdata,1)
    if length(resolutionaxis)>1 %recalculate peakshape
        peakshape=peak_width_adaption(shape,molecule.com/resolutionaxis(mass2ind(massaxis,molecule.com)),area);
    end
    evalspline=peakshape;
    evalspline.breaks=evalspline.breaks+molecule.peakdata(i,1);
    ind=find(evalspline.breaks(1)<massaxis & evalspline.breaks(end)>massaxis);
    out=out+sparse(ones(size(ind)),ind,molecule.peakdata(i,2)*double(ppval(evalspline,massaxis(ind))),1,l);
    
    %out(ind)=out(ind)+sparse(molecule.peakdata(i,2)*ppval(evalspline,massaxis(ind)));
end

%int(out*dx)=area

%convolution:
