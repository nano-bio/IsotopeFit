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
%[~,ix]=sort(arealist); %start with lowest molecule

molecules=molecules(ix);

spec_calc=zeros(1,size(peakdata,1));
%indtest=findmassrange(massaxis,molecules,1000,0,10);

%maximally used datapoints for fitting
maxdatapoints=1000;

for i=1:l
    drawnow;
    
    involved=findinvolvedmolecules(molecules,i:l,i,0.3);
    
    nmolecules=length(involved);
    parameters=zeros(1,nmolecules+2);
    fprintf('Fitting molecule %i of %i (%i molecules involved)\n',i,l,nmolecules);
    
    k=1;
    for j=involved
        if molecules{j}.area==0 %dirty workaround: when area=0, no fitting. dont know why!
            parameters(k)=0.1;
        else
            parameters(k)=molecules{j}.area;
        end
        k=k+1;
    end
    
    parameters(nmolecules+1)=resolutionbycalibration(calibration,molecules{i}.com); %resolution
    parameters(nmolecules+2)=massoffsetbycalibration(calibration,molecules{i}.com); %x-offset
    
    ind=findmassrange(massaxis,molecules(involved),parameters(nmolecules+1),parameters(nmolecules+2),10);
    %ind=findmassrange2(massaxis,ranges{i}.molecules,ranges{i}.resolution,ranges{i}.massoffset,0.5);
    
    %is it necessary to cut out some datapoints?
    ndp=length(ind); %number of datapoints
    if ndp>maxdatapoints %then cut out some datapoints
        ind=ind(round((1:maxdatapoints)*(ndp/maxdatapoints)));%ind will be maxdatapoints long
    end
    
    %define upper and lower bound for fitting process:
    lb=[zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam];
    ub=[ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam];
    
    %simplex fitting:
    fitparam=fminsearchbnd(@(x) msd(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),x),parameters,...
                          lb,ub,optimset('MaxFunEvals',5000,'MaxIter',5000));
    
    %Genetic algorithm
%      opt = gaoptimset('PopInitRange',[parameters/2;parameters*2]);
%      opt = gaoptimset(opt,'EliteCount',2*length(parameters));
%      opt = gaoptimset(opt,'PopulationSize',50*length(parameters));
%      opt = gaoptimset(opt,'Display','iter');
%      opt = gaoptimset(opt,'TolFun',0.1);
%      fitparam = ga(@(x) msd(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),x),length(parameters),...
%                        [],[],[],[],lb,ub,[],opt);
    
    %fprintf('Error estimation...\n');
    %error estimation
     
    dof=length(ind)-2;
    sdrq = (msd(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),fitparam))/dof;
    %J = jacobianest(@(x) multispecparameters(massaxis(ind)-spec_calc(ind),molecules(involved),x),fitparam);
    HD = hessdiag(@(x) msd(massaxis(ind)-spec_calc(ind),massaxis(ind),molecules(involved),x)/dof,fitparam);
    
%     sigma = sdrq*pinv(J'*J);
%    stderr = sqrt(diag(sigma))';

   % stderr=sqrt(sdrq./diag(J'*J)');
    stderr=sqrt(sdrq./HD');

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

