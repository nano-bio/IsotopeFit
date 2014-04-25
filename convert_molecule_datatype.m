function molecules_out=convert_molecule_datatype(molecules_in)
% compatibility: in old files, molecules were organized in cell
% arrays. now they are a struct array.
% this function returns a struct array from both, old and new
% molecule datastructure
if iscell(molecules_in)
    fprintf('Found old molecules-datatype. Converting... ');
    molecules_out=[molecules_in{:}];
    fprintf('done.\n');
else
    molecules_out=molecules_in;
end

end

