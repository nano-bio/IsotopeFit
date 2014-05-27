function out= getcalibrationdata(x,y,param,methode,axis)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
switch lower(methode)
    case 'flat'
        out=ones(size(axis,1),size(axis,2))*param;
    case 'polynomial'
        p=polyfit(x,y,param);
        out=polynomial(p,axis);
    case 'spline'
        out=splinemod(x,y,axis);
    case 'pchip'
        out=pchipmod(x,y,axis);
    case 'spaps'
        out=fnval(spaps(x,y,exp(param)),axis);
end


end

