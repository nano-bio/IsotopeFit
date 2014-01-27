function out = fitmolecules(peakdata,molecules,calibration,areaup,deltares,deltam)
%out = fitranges(peakdata,ranges)
%   fits molecules organized in ranges to peakdata
%   fits area, resolution and massoffset

massaxis=peakdata(:,1)';
spec_measured=peakdata(:,2)';

l=length(molecules);

h = waitbar(0,'Please wait...'); 

arealist=[];
for i=1:l
    arealist(i)=molecules{i}.area;
end

[~,ix]=sort(0-arealist); %start with highest molecule

molecules=molecules(ix);

spec_calc=zeros(1,size(peakdata,1));
indtest=findmassrange(massaxis,molecules,1000,0,10);
for i=1:l
    drawnow;
    
    involved=findinvolvedmolecules(molecules,i:l,i,0.3);
    
    nmolecules=length(involved);
    parameters=zeros(1,nmolecules+2);
    fprintf('Fitting molecule %i of %i (%i molecules involved)\n',i,l,nmolecules);
    
    k=1;
    for j=involved
        parameters(k)=molecules{j}.area;
        k=k+1;
    end
    
    parameters(nmolecules+1)=resolutionbycalibration(calibration,molecules{i}.com); %resolution
    parameters(nmolecules+2)=massoffsetbycalibration(calibration,molecules{i}.com); %x-offset
        
    ind=findmassrange2(massaxis,molecules(involved),parameters(nmolecules+1),parameters(nmolecules+2),10);
    %ind=findmassrange2(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,0.5);
    
    fitparam=fminsearchbnd(@(x) msd(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),x),parameters,...
        [zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam],...
        [ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam],...
        optimset('MaxFunEvals',5000,'MaxIter',5000));
    
    %fprintf('Error estimation...\n');
    %error estimation
     
    dof=sum(ind)-2;
    sdrq = (msd(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),fitparam))/dof;
    J = jacobianest(@(x) multispecparameters(massaxis(ind)-spec_calc(ind),molecules(involved),x),fitparam);
    sigma = sdrq*pinv(J'*J);
    %sigma = b/(J'*J);
    
    stderr = sqrt(diag(sigma))';
    
        
    %update calculated spec
    spec_calc=spec_calc+multispecparameters(massaxis,molecules(i),fitparam([1,end-1,end]));
    
    %plot(axes,massaxis(indtest),spec_measured(indtest)-spec_calc(indtest));
    
    k=1;
    for j=involved
        molecules{j}.area=fitparam(k); %read out fitted areas for every molecule
        molecules{j}.areaerror=stderr(k); %read out fitted areas for every molecule
        k=k+1;
    end

    waitbar(i/l);
end
fprintf('Done.\n')
close(h);

out(ix)=molecules;

end

