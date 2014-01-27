function out = splinemod(x,y,xx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if length(x)==1
    out=ones(size(xx,1),size(xx,2))*y(1);
else
    out=double(spline(x,y,xx));
end

end

