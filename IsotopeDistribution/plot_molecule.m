function plot_molecule(string,minmassdistance,th)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

d=parse_molecule(string,minmassdistance,th);
d(:,2)=d(:,2)/max(d(:,2))*100; %renormation;

stem(d(:,1),d(:,2),'filled','k');

end

