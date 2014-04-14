function [paramsout,errout] = get_fit_params_using_simplex(spec_measured,massaxis,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

paramsout=fminsearchbnd(@(x) msd(spec_measured,massaxis,molecules,x),parameters,...
    lb,ub,optimset('MaxFunEvals',5000,'MaxIter',5000));


errout=get_fitting_errors(spec_measured,massaxis,molecules,paramsout,0.5);

end

