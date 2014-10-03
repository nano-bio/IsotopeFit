function plot_molecule(string,minmassdistance,th)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

d=parse_molecule(string,minmassdistance,th);
%d(:,2)=d(:,2)/max(d(:,2))*100; %renormation;

for i=1:size(d,1)
    fprintf('%10.10f\t%10.10f\n',d(i, 1),d(i, 2));
end

stem(d(:,1),d(:,2),'filled','k');
xlim([min(d(:,1))-1,max(d(:,1))+1]);
xlabel('Mass (Dalton)','FontSize',24);
ylabel('Abundance','FontSize',24);

set(gca,'FontSize',20);

end

