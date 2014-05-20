function out= getcalibrationdata(x,y,param,methode,axis)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
switch methode
    case 'Flat'
        out=ones(size(axis,1),size(axis,2))*param;
    case 'Polynomial'
        p=polyfit(x,y,param);
        out=polynomial(p,axis);
    case 'Spline'
        out=splinemod(x,y,axis);
    case 'PChip'
        out=pchipmod(x,y,axis);
    case 'spaps'
        out=fnval(spaps(x,y,exp(param)),axis);
end


end

