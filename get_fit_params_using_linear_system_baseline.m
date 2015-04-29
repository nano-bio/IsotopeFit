function [paramsout,errout] = get_fit_params_using_linear_system_baseline(spec_measured,massaxis,shape,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Pre-allocate space for Matrix:
% lines:number of datapoints,
% columns: number of molecules

M=zeros(length(massaxis),length(molecules)+1);

%fill matrix with isotopic pattern for every molecule
for j=1:length(molecules)
    M(:,j)=double(pattern(molecules(j),1,parameters(end-1),parameters(end),massaxis,shape)');
end

M(:,end)=ones(size(massaxis'))/(massaxis(end)-massaxis(1));

[A,~,residual] = lsqnonneg(M,double(spec_measured)');

paramsout=parameters;
paramsout(1:end-2)=A(1:end-1)';

%errout=get_fitting_errors(spec_measured,massaxis,molecules,paramsout,1)'

%errors are residuals of variables. doesn't provide errors for resolution
%and massoffset
%errout=[error_est,NaN,NaN];

errout=1.96*diag(sqrt(inv(M'*M)*sum(((M*A)'-spec_measured).^2)/(length(spec_measured-length(A)))));
errout(end+1)=0; %resolution
errout(end+2)=0; %mass offset
% 
% for i=1:length(molecules)
%     fprintf('Molecule: %s\t\tArea: %f +- %f\n',molecules(i).name,molecules(i).area,molecules(i).areaerror);
% end

%errout=NaN(size(paramsout));

end

