function plotresolution(ranges)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(ranges)
    data(i)=ranges{i}.resolution;
    dataerror(i)=ranges{i}.resolutionerror;
end

p=stem(data,'filled','+k'); hold on;
%set(p,'FaceColor','none');
%p=errorbar(data,dataerror,'.k'); hold off;
set(p,'LineWidth',2);

p=stem(data+dataerror,'Marker','v','Color','b','LineStyle','none');
p=stem(data-dataerror,'Marker','^','Color','b','LineStyle','none');


hold off;

end

