function out = renorm(d)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

d(:,2)=d(:,2)/max(d(:,2))*100;
out=d;

end

