function [paramsout,errout] = get_fit_params_using_simplex_lin_combi(spec_measured,massaxis,shape,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% problem.objective=@(x) msd_without_areas(spec_measured,massaxis,molecules,x);
% problem.x0=parameters(end-1:end);
% problem.lb=lb(end-1:end);
% problem.ub=ub(end-1:end);
% problem.solver='fmincon';
% problem.options = optimoptions('fmincon','GradObj','off');
% 
% sigmamu=fmincon(problem);

sigmamu=fminsearchbnd(@(x) msd_without_areas(spec_measured,massaxis,shape,molecules,x),parameters(end-1:end),...
    lb(end-1:end),ub(end-1:end),optimset('MaxFunEvals',5000,'MaxIter',5000));

paramin=[zeros(1,length(molecules)),sigmamu];
[paramsout,~] = get_fit_params_using_linear_system(spec_measured,massaxis,shape,molecules,paramin,lb,ub);

%errout=get_fitting_errors(spec_measured,massaxis,molecules,paramsout,0.5);
errout=NaN(1,length(molecules)+2);
end

