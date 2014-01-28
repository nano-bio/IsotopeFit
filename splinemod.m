function out = splinemod(x,y,xx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if length(x)==1
    out=ones(size(xx,1),size(xx,2))*y(1);
else
    %prevent explosion fo y values in extrapolation region
%     p=polyfit(x,y,1); %linear function
%     x=[massaxis(1),x,massaxis(end)];
%     y=[polynomial(p,massaxis(1)),y,polynomial(p,massaxis(end))];
    out=double(spline(x,y,xx));
end

end

