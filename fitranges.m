function out = fitranges(peakdata,ranges,areaup,deltares,deltam)
%out = fitranges(peakdata,ranges)
%   fits molecules organized in ranges to peakdata
%   fits area, resolution and massoffset

massaxis=peakdata(:,1)';
spec_measured=peakdata(:,2)';

l=length(ranges);

h = waitbar(0,'Please wait...'); 



for i=1:l
    
    drawnow;
    nmolecules=length(ranges{i}.molecules);
    parameters=zeros(1,nmolecules+2);
    fprintf('Fitting massrange %i (%5.1f - %5.1f): %i molecules\n',i, ranges{i}.minmass,ranges{i}.maxmass,nmolecules);
    for j=1:nmolecules
        parameters(j)=ranges{i}.molecules{j}.area;
    end
    parameters(nmolecules+1)=ranges{i}.resolution; %resolution
    parameters(nmolecules+2)=ranges{i}.massoffset; %x-offset
     
    
    %[minind,maxind]=findmassrange(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,10);
    ind=findmassrange(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,10);
    %ind=findmassrange2(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,0.5);
    
    %fitparam=fminsearch(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),parameters,optimset('MaxFunEvals',10000,'MaxIter',10000));
    fitparam=fminsearchbnd(@(x) msd(spec_measured(ind),massaxis(ind),ranges{i}.molecules,x),parameters,...
        [zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam],...
        [ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam],...
        optimset('MaxFunEvals',5000,'MaxIter',5000));
    
    %fprintf('Error estimation...\n');
    %error estimation
    
    dof=sum(ind)-2;
    sdrq = (msd(spec_measured(ind),massaxis(ind),ranges{i}.molecules,fitparam))/dof;
    J = jacobianest(@(x) multispecparameters(massaxis(ind),ranges{i}.molecules,x),fitparam);
    sigma = sdrq*pinv(J'*J);
    %sigma = b/(J'*J);
    
    stderr = sqrt(diag(sigma))';
    
    for j=1:nmolecules
        ranges{i}.molecules{j}.area=fitparam(j); %read out fitted areas for every molecule
        ranges{i}.molecules{j}.areaerror=stderr(j); %read out fitted areas for every molecule
    end
    
    ranges{i}.massoffset=fitparam(end);
    ranges{i}.resolution=fitparam(end-1);
    ranges{i}.massoffseterror=stderr(end);
    ranges{i}.resolutionerror=stderr(end-1);
    waitbar(i/l);
end
fprintf('Done.\n')
close(h);

out=calccomofranges(ranges);

end

