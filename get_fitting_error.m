function errout = get_fitting_error(spec_measured,massaxis,molecule,molecules_involved,calibration)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

dof=length(massaxis)-2;
%sdrq = (msd(spec_measured(inderr),massaxis(inderr),molecules,parameters))/dof;

areas=zeros(1,length(molecules_involved));
M=zeros(length(massaxis),length(molecules_involved));
for j=1:length(molecules_involved)
    M(:,j)=double(pattern_func(molecules_involved(j),1,resolutionbycalibration(calibration,molecules_involved(j).com),0,massaxis)',calibration.shape);
    areas(j)=molecules_involved(j).area;
end

molecule_pattern=double(pattern_func(molecule,1,resolutionbycalibration(calibration,molecule.com),0,massaxis)',calibration.shape);

sum_spec=M*areas'+molecule_pattern*molecule.area;

%plot(massaxis,sum_spec,massaxis,spec_measured);
%drawnow
rel_error=sum(abs(spec_measured'-sum_spec))/sum(sum_spec);
%rel_error=std(spec_measured'-sum_spec)./(mean(sum_spec)*sqrt(length(spec_measured)))

if length(molecules_involved)==0
    %errout=molecule.area*std((spec_measured'-(sum_spec))./length(sum_spec));
    errout=molecule.area*rel_error;
    %errout=molecule.area./sqrt(sum(molecule_pattern));
else
    %counts=sum(M.*repmat(areas,size(M,1),1),1); %total counts per molecule
    
    %sigma_area=parameters(1:end-2)./sqrt(counts); %deviation in area. linary scaled: sigma_area=sigma_counts*areas/counts=sqrt(counts)*areas/counts
    
    %sigma_area=areas*std((spec_measured'-sum_spec)./sum_spec); %deviation in area.
    %sigma_area=areas*sqrt(sum((spec_measured'-sum_spec).^2)./length(sum_spec)); %deviation in area.
    sigma_area=areas*rel_error; %deviation in area.
    %sigma_area=areas./sqrt(counts); %deviation in area.
    %sigma_area(isnan(sigma_area))=0; %if sigma=0, a/sigma gives nan
    
    %sigma_m=sigma_area'*sigma_area %input variance matrix --> sigma1*sigma2
    sigma_m=inv(M'*M)*var(spec_measured'-sum_spec)
    
    
    J=jacobianest(@(x) area_left(spec_measured,M,x,molecule_pattern),areas);
    
    %sigma_sqr=J*cov(M(:,m_ind).*repmat(parameters(m_ind),size(M,1),1))*J';
    
    % sigma_sqr... output covariance matrix
    % cov(x1,x2)=corrcoef(x1,x2)*sigma1*sigma2
    % sigma_sqr = J*cov*J'
    % sigma_sqr=J*(corrcoef(M).*sigma_m)*J';
    sigma_sqr=J*sigma_m*J';
    errout=1.95*sqrt(sigma_sqr); %1.95 -> confidence level of 95% for student t distribution with infinite dof.
end

% (cov(M.*repmat(parameters(1:end-2),size(M,1),1)))
% (corrcoef(M).*counts_m)

%errout=errout./counts %normalize errors

%errout.*parameters(1:end-2)


%error estimation via "squared" Jacobian matrix (first derivatives squared)

%J = jacobianest(@(x) sum(multispecparameters(massaxis(inderr),molecules,x)),parameters);

%J = jacobianest(@(x) sqrt(msd(spec_measured(inderr),massaxis(inderr),molecules,x))/dof,parameters);

%size(J)
%size(cov(M))

%sigma_sqr=J(:,1:end-2)*cov(M)*J(:,1:end-2)';
%errout=sqrt(diag(sigma_sqr))


%sigma = sdrq*pinv(J'*J);
%errout = sqrt(diag(sigma))';

% error estimation via diagonal elements of hessian matrix (=second derivatives)
% HD = hessdiag(@(x) msd(spec_measured(inderr),massaxis(inderr),molecules,x)/dof,parameters);
% errout=sqrt(sdrq./HD');
% errout=zeros(size(parameters));

end

function out=area_left(spec_measured,M,areas,molecule_spec)
    spec_left=spec_measured-(M*areas')';
    
%     plot(spec_left)
%     drawnow();
    %fit the left-over-area;
    out=lsqnonneg(double(molecule_spec),double(spec_left'));
    %out=sum(spec_left);
end
%% 

