function plot_allmolecules(massaxis,molecules)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

resolution=500;
offset=0;
param=[]
names={};
for i=1:length(molecules)
    subparam=molecules{i}.area;
    param=[param subparam];
    names{i}=molecules{i}.name;
    plot(massaxis,multispec(massaxis,molecules(i),[subparam  resolution offset]));
    set(gca,'NextPlot','add');
end
names{end+1}='Sum';
plot(massaxis,multispec(massaxis,molecules,[param resolution offset]));
legend(names);


end

