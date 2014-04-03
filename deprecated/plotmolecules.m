function plotmolecules(ranges)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

moleculecount=1;
for i=1:length(ranges)
    for j=1:length(ranges{i}.molecules)
        data(moleculecount)=ranges{i}.molecules{j}.area;
        dataerror(moleculecount)=ranges{i}.molecules{j}.areaerror;
        com(moleculecount)=ranges{i}.molecules{j}.centerofmass;
        labels{moleculecount}=ranges{i}.molecules{j}.name;
        moleculecount=moleculecount+1;
    end
end

p=stem(com,data,'filled','+k'); hold on;
%set(p,'FaceColor','none');
%p=errorbar(data,dataerror,'.k'); hold off;
%set(p,'LineWidth',2);
%set(gca,'XTick',1:length(labels),'XTickLabel',labels);

p=stem(com,data+dataerror,'Marker','v','Color','b','LineStyle','none');
p=stem(com,data-dataerror,'Marker','^','Color','b','LineStyle','none');

hold off;

end

