function [ out_molecules ] = remove_out_of_range_molec(molecules, peakdata )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% need to check if any of the molecules are out of range
molec_minmasses = [molecules.minmass];
molec_in_range = (molec_minmasses<peakdata(end,1));
                        
out_molecules = convert_molecule_datatype(molecules(molec_in_range));
            
% need to update rootindex (needed for molecule grouping)
for i = 1:length(molecules)
    molecules(i).rootindex=i;
end
            
% print molecules that are out of range
molec_out_of_range_name = {molecules(~molec_in_range).name};
for i=1:length(molec_out_of_range_name)
    fprintf('Molecule %s out of range\n',molec_out_of_range_name{i});
end
fprintf('\n%i molecules out of massrange\n',length(molec_out_of_range_name));

end
