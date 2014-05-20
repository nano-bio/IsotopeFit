function [paramsout,errout] = get_fit_params_using_simplex_lin_combi(spec_measured,massaxis,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

sigmamu=fminsearchbnd(@(x) msd_without_areas(spec_measured,massaxis,molecules,x),parameters(end-1:end),...
    lb(end-1:end),ub(end-1:end),optimset('MaxFunEvals',5000,'MaxIter',5000));

paramin=[zeros(1,length(molecules)),sigmamu];
[paramsout,~] = get_fit_params_using_linear_system(spec_measured,massaxis,molecules,paramin,lb,ub);

errout=get_fitting_errors(spec_measured,massaxis,molecules,paramsout,0.5);

end

