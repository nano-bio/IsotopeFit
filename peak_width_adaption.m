function out = peak_width_adaption(shape,fwhm,area)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

out=shape;

% peak width adaption:
% shrink/strech x-points of spline
% and adapt coefficients accordingly
out.breaks=out.breaks*fwhm;
out.coefs=out.coefs./(fwhm.^repmat([3 2 1 0],size(out.coefs,1),1));

if fwhm<0 % make peakshape robust for negative resolution
    out.breaks=out.breaks(end:-1:1);
    out.coefs=out.coefs(end:-1:1,:);
end

% peak area adaption
% original peak has an area of 1.
% we need to restore this area after the change of the x-coordinates
out.coefs=out.coefs*area/fwhm;


end

