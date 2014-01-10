function out = ten2variablesystem(numin,system)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

out=zeros(1,length(system));

for i=1:length(system)-1
    out(i)=mod(numin,system(i));
    numin=floor(numin/system(i));
end

out(end)=mod(numin,system(end));


end

