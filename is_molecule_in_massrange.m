function out=is_molecule_in_massrange(molecule,minmass,maxmass)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

out=(((molecule.minmass<=maxmass)&&(molecule.minmass>=minmass))||...
       ((molecule.maxmass<=maxmass)&&(molecule.maxmass>=minmass))||...
       ((molecule.minmass<=minmass)&&(molecule.maxmass>=maxmass)));

end

