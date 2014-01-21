function out = findmassrange(massaxis,molecules,resolution,massoffset,factor)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

com=calccomofmolecules(molecules);
sigma=com/resolution*(1/(2*sqrt(2*log(2)))); %guess sigma by center of mass of first molecule

minmass=molecules{1}.minmass+massoffset-factor*sigma;
maxmass=molecules{end}.maxmass+massoffset+factor*sigma;

% minind=mass2ind(massaxis,minmass);
% maxind=mass2ind(massaxis,maxmass);


out=massaxis>=minmass&massaxis<=maxmass;

end

