function molecules_out = load_molecules_from_ifm(file,peakdata)
%loadmolecules( moleculelist,massaxis,startvalues )
%Output stucture: out{l} cell array of length l with following fields:
%out.peakdata... [mass, rel.abundance]
%out.name... filename without .txt
%out.area... first guess of molecule abundance via data integration
%out.centerofmass... masscenter of molecule
%out.minmass(maxmass)... minimum (maximum) mass of molecule
%out.minind(maxind)... minimum (maximum) index in spectrum data

fprintf('Loading molecule peakdata...\n');

data={}; %load needs a predefined variable
load(file,'-mat');

fprintf('\nDone.\n')

masses=[];
peaks=[];
massaxis=peakdata(:,1)';
minmasses=zeros(1,length(data.molecules));

molecules_out = init_molecule_properties(data.molecules,peakdata);

end

