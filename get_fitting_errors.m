function errout = get_fitting_errors(spec_measured,massaxis,molecules,parameters,searchrange)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

errout=zeros(1,length(molecules)+2);

dof=length(massaxis)-2;
%sdrq = (msd(spec_measured(inderr),massaxis(inderr),molecules,parameters))/dof;

for j=1:length(molecules)
    M(:,j)=double(pattern(molecules(j),1,parameters(end-1),parameters(end),massaxis)');
end

 counts=sum(M.*repmat(parameters(1:end-2),size(M,1),1),1); %total counts per molecule
 %sigma_area=parameters(1:end-2)./sqrt(counts); %deviation in area. linary scaled: sigma_area=sigma_counts*areas/counts=sqrt(counts)*areas/counts
 sigma_area=parameters(1:end-2)./counts*sum(abs(spec_measured'-M*parameters(1:end-2)')); %deviation in area.
 
 sigma_area(isnan(sigma_area))=0; %if sigma=0, a/sigma gives nan 
 
 sigma_m=sigma_area'*sigma_area; %input variance matrix --> sigma1*sigma2

for j=1:length(parameters)-2
    %select all molecules but the one we are intrested in
    m_ind=setdiff(1:size(M,2),j);
        
    J=jacobianest(@(x) area_left(spec_measured,M(:,m_ind),x,M(:,j)),parameters(m_ind));
    
    %sigma_sqr=J*cov(M(:,m_ind).*repmat(parameters(m_ind),size(M,1),1))*J';
        
    % sigma_sqr... output covariance matrix
    % cov(x1,x2)=corrcoef(x1,x2)*sigma1*sigma2
    % sigma_sqr = J*cov*J'        
    sigma_sqr=J*(corrcoef(M(:,m_ind)).*sigma_m(m_ind,m_ind))*J';
    
    errout(j)=sqrt(sigma_sqr);
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

