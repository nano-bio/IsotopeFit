function out = fitranges(peakdata,ranges,areaup,deltares,deltam)
%out = fitranges(peakdata,ranges)
%   fits molecules organized in ranges to peakdata
%   fits area, resolution and massoffset

massaxis=peakdata(:,1)';
spec_measured=peakdata(:,2)';

l=length(ranges);

%check if there are too much molecules per range
maxmolperrange=1;
for i=1:l
    maxmolperrange=max(length(ranges{i}.molecules),maxmolperrange);
end

if maxmolperrange>10
    choice = questdlg(sprintf('At least in one range, there are more then 10 molecules (max: %i). Do you want to continue?',maxmolperrange), ...
        'Fit Ranges', ...
        'Yes','No','No');
    % Handle response
    drawnow;
    
    if strcmp(choice,'No')
        out=ranges;
        return;
    end
end

% this should give us a computational pool with a worker for each cpu
if matlabpool('size')==0 %check if pool is already open
    parpool(feature('numcores'))
end

% we use a copy of the original ranges variable,
% because parfor cannot access the original one! 
rangestemp=ranges;

%maximally used datapoints for fitting
maxdatapoints=1000;

h = waitbar(0,'Please wait...'); 
parfor i=1:l
    nmolecules=length(ranges{i}.molecules)
    parameters=zeros(1,nmolecules+2);
    fprintf('%i/%i (%5.1f - %5.1f): %i molecules\n',i,l, ranges{i}.minmass,ranges{i}.maxmass,nmolecules);
       
    ind=findmassrange(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,10);
    
    %is it necessary to cut out some datapoints?
    ndp=length(ind); %number of datapoints
    if ndp>maxdatapoints %then cut out some datapoints
        ind=ind(round((1:maxdatapoints)*(ndp/maxdatapoints)));%ind will be maxdatapoints long
    end
    
    for j=1:nmolecules
        if ranges{i}.molecules{j}.area==0 %dirty workaround: when area=0, no fitting. dont know why!
            parameters(j)=0.1;
        else
            parameters(j)=ranges{i}.molecules{j}.area;
        end
        parameters(j)=max(0,sum(peakdata(ind,2).*[0;diff(peakdata(ind,1))]));%integrate over peak to estimate area
    end
        
    parameters(nmolecules+1)=ranges{i}.resolution; %resolution
    parameters(nmolecules+2)=ranges{i}.massoffset; %x-offset
        
    %fitparam=fminsearch(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),parameters,optimset('MaxFunEvals',10000,'MaxIter',10000));
    drawnow;
    
    fitparam=fminsearchbnd(@(x) msd(spec_measured(ind),massaxis(ind),ranges{i}.molecules,x),parameters,...
        [zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam],...
        [ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam],...
        optimset('MaxFunEvals',5000,'MaxIter',5000));
   
    %fprintf('Error estimation...\n');
    %error estimation
    
    %for error estimation, use a small range around the peak maxima
    inderr=findmassrange2(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,0.5);
    
    dof=length(inderr)-2;
    sdrq = (msd(spec_measured(inderr),massaxis(inderr),ranges{i}.molecules,fitparam))/dof;
    
    %error estimation via "squared" Jacobian matrix (first derivatives squared)
    %J = jacobianest(@(x) multispecparameters(massaxis(ind),ranges{i}.molecules,x),fitparam);
    %sigma = sdrq*pinv(J'*J);
    %stderr = sqrt(diag(sigma))';
    
   %error estimation via diagonal elements of hessian matrix (=second derivatives)
   HD = hessdiag(@(x) msd(spec_measured(inderr),massaxis(inderr),ranges{i}.molecules,x)/dof,fitparam); 
   stderr=sqrt(sdrq./HD');
    
   %write fitparameters to molecules structure
    for j=1:nmolecules
        rangestemp{i}.molecules{j}.area=fitparam(j); %read out fitted areas for every molecule
        rangestemp{i}.molecules{j}.areaerror=stderr(j); %read out fitted areas for every molecule
    end
    
    rangestemp{i}.massoffset=fitparam(end);
    rangestemp{i}.resolution=fitparam(end-1);
    rangestemp{i}.massoffseterror=stderr(end);
    rangestemp{i}.resolutionerror=stderr(end-1);
end
fprintf('Done.\n')
close(h);

%center of mass of ranges needs to be recalculated due to different areas
%of involved molecules:
out=calccomofranges(rangestemp);

end

