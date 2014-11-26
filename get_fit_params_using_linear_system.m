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

% estimate errors using residuals
% see http://en.wikipedia.org/wiki/Studentized_residual: Internal and external studentization

% m=length(A);
% n=length(spec_measured);
% %Ahat=(M'*M)\(M'*double(spec_measured)');
% Ahat=lsqnonneg((M'*M),(M'*double(spec_measured)'));
% 
% s2=norm(A-Ahat)^2/(n-m);
% covar=s2*inv(M'*M);
% sqrt(covar)
% error_est=sqrt(diag(covar))'
% 
 paramsout=parameters;
 paramsout(1:end-2)=A';

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

