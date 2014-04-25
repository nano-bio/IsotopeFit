function [paramsout,errout] = get_fit_params_using_linear_system(spec_measured,massaxis,molecules,parameters,lb,ub)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Pre-allocate space for Matrix:
% lines:number of datapoints,
% columns: number of molecules
M=zeros(length(massaxis),length(molecules));

%fill matrix with isotopic pattern for every molecule
for j=1:length(molecules)
    M(:,j)=double(pattern(molecules(j),1,parameters(end-1),parameters(end),massaxis)');
end

% left division gives vector of areas
%A=M\spec_measured';
[A,~,residual] = lsqnonneg(M,double(spec_measured)');

paramsout=parameters;
paramsout(1:end-2)=A';

%errors are residuals of variables. doesn't provide errors for resolution
%and massoffset
errout=[residual',NaN,NaN];

end

