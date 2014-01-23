function out=approx_p(distribution,th)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

ix=distribution(:,2)>=th*max(distribution(:,2));

out=renorm(distribution(ix,:));
end

