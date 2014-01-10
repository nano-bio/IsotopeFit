moleculelist={};
for i=1:10
  moleculelist{i*2-1}=['petpeak' int2str(i)];
  moleculelist{i*2}=['petpeak' int2str(i) 'H'];
end

startvalues=[ones(1,2*10)*0.05 3000 0];

fitmolecules('test2.txt', moleculelist,5,startvalues)

