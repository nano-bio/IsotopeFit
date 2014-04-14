function errout = get_fitting_errors(spec_measured,massaxis,molecules,parameters,searchrange)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% for error estimation, use a small range around the peak maxima
inderr=findmassrange2(massaxis,molecules,parameters(end-1),parameters(end),searchrange);

dof=length(inderr)-2;
sdrq = (msd(spec_measured(inderr),massaxis(inderr),molecules,parameters))/dof;

%error estimation via "squared" Jacobian matrix (first derivatives squared)
%J = jacobianest(@(x) multispecparameters(massaxis(ind),ranges{i}.molecules,x),fitparam);
%sigma = sdrq*pinv(J'*J);
%stderr = sqrt(diag(sigma))';

% error estimation via diagonal elements of hessian matrix (=second derivatives)
HD = hessdiag(@(x) msd(spec_measured(inderr),massaxis(inderr),molecules,x)/dof,parameters);
errout=sqrt(sdrq./HD');


end

