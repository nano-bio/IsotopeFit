folder='Z:\Experiments\STM\matlab\IsotopeFit\IsotopeDistribution\molecules\test\';
moleculelist=foldertolist(folder);

xaxis=[700:0.01:750];
signal=zeros(1,length(xaxis));
molecules=loadmolecules(folder,moleculelist,[xaxis;signal]);


molecules{1}.area=10;
molecules{2}.area=1;

resolution=3000;

%multispec(molecules,resolution,massoffset,massaxis);
M=xaxis';

sum=multispec(molecules,resolution,0,xaxis);
plot(xaxis,sum);
hold on;

for i=1:length(moleculelist)
    s(i,:)=multispec(molecules(i),resolution,0,xaxis);
    M=[M,s(i,:)'];
    plot(xaxis,s(i,:));
end

dlmwrite('out.txt',M,'delimiter','\t','precision', '%e');
