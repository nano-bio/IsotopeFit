moleculelist={};
for i=1:7
  moleculelist{i*3-2}=['PET' int2str(i)];
  moleculelist{i*3-1}=['PET' int2str(i) '-H'];
  moleculelist{i*3}=['PET' int2str(i) 'H'];
end

moleculelist{end+1}='He34';

startvalues=[ones(1,3*7+1)*0.05 3000 0];

fitmolecules('test.txt', moleculelist,5,startvalues)

