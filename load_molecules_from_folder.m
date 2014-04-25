function molecules_out = load_molecules(folder,moleculelist,peakdata)
%loadmolecules( moleculelist,massaxis,startvalues )
%Output stucture: out{l} cell array of length l with following fields:
%out.peakdata... [mass, rel.abundance]
%out.name... filename without .txt
%out.area... first guess of molecule abundance via data integration
%out.centerofmass... masscenter of molecule
%out.minmass(maxmass)... minimum (maximum) mass of molecule
%out.minind(maxind)... minimum (maximum) index in spectrum data
%out.useforcal... boolean, 1:use this molecule for massaxis/resolution
%                            calibration

fprintf('Loading molecule peakdata...\n');

% minmasses=zeros(1,length(moleculelist));
% maxmasses=zeros(1,length(moleculelist));
hwb=waitbar(0,'Loading molecule peakdata...');
drawnow;
l=length(moleculelist);
for i=1:l
    molecules_out(i).peakdata=renorm(load([folder '\' moleculelist{i}]));
    molecules_out(i).name=moleculelist{i}(1:end-4);
    if mod(i,10)==0,  waitbar(i/l); end;
end

close(hwb);

fprintf('\nDone.\n')

molecules_out = init_molecule_properties(molecules_out,peakdata);

end

