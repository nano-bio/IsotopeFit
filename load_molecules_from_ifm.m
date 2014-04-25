function molecules_out = load_molecules_from_ifm(file,peakdata)
%loadmolecules( moleculelist,massaxis,startvalues )
%Output stucture: out{l} cell array of length l with following fields:
%out.peakdata... [mass, rel.abundance]
%out.name... filename without .txt
%out.area... first guess of molecule abundance via data integration
%out.centerofmass... masscenter of molecule
%out.minmass(maxmass)... minimum (maximum) mass of molecule
%out.minind(maxind)... minimum (maximum) index in spectrum data

fprintf('Loading molecule peakdata... ');

data=[]; %load needs a predefined variable
load(file,'-mat');

fprintf('done.\n')

molecules_out = init_molecule_properties(convert_molecule_datatype(data.molecules),peakdata);

end

