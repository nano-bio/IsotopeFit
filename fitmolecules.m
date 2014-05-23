function out = fitmolecules(peakdata,molecules,calibration,areaup,deltares,deltam,fitting_method)
%out = fitranges(peakdata,ranges)
%   fits molecules organized in ranges to peakdata
%   fits area, resolution and massoffset

massaxis=peakdata(:,1)';
spec_measured=peakdata(:,2)';

l=length(molecules);

h = waitbar(0,'Please wait...');

arealist=[];
for i=1:l
    arealist(i)=molecules(i).area;
end

%[~,ix]=sort(0-arealist); %start with highest molecule
%[~,ix]=sort(arealist); %start with lowest molecule
%molecules=molecules(ix);

spec_calc=zeros(1,size(peakdata,1));
%indtest=findmassrange(massaxis,molecules,1000,0,10);

fprintf('Start fitting %i molecules using %s\n',l, fitting_method);

searchrange=3; %look for molecules within this sigma-range.

for i=1:l
    drawnow;
    
    resolution=resolutionbycalibration(calibration,molecules(i).com); %resolution
    massoffset=massoffsetbycalibration(calibration,molecules(i).com); %x-offset
    
    ind=findmassrange(massaxis,molecules(i),resolution,massoffset,searchrange);
    %ind=findmassrange2(massaxis,molecules(i),parameters(nmolecules+1),parameters(nmolecules+2),0.5);
    involved=molecules_in_massrange_with_sigma(molecules(i:l),massaxis(ind(1)),massaxis(ind(end)),calibration,searchrange)'+(i-1);
    
    %maximally used datapoints for fitting per molecule
    maxdatapoints=50*length(involved);
    
    nmolecules=length(involved);
    parameters=zeros(1,nmolecules+2);
    fprintf('Fitting molecule %i of %i (%i molecules involved)\n',i,l,nmolecules);
    
    k=1;
    for j=involved
        molecules(j).area;
        if molecules(j).area==0 %dirty workaround: when area=0, no fitting. dont know why!
            parameters(k)=0.1;
        else
            parameters(k)=molecules(j).area;
        end
        k=k+1;
    end
    
    parameters(nmolecules+1)=resolution;
    parameters(nmolecules+2)=massoffset;
 
    %is it necessary to cut out some datapoints?
    ndp=length(ind); %number of datapoints
    if ndp>maxdatapoints %then cut out some datapoints
        ind=ind(round((1:maxdatapoints)*(ndp/maxdatapoints)));%ind will be maxdatapoints long
    end
    
    %define upper and lower bound for fitting process:
    lb=[zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam];
    ub=[ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam];
    
    switch fitting_method
        case 'linear_system'
            [fitparam,stderr]=get_fit_params_using_linear_system(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),parameters,lb,ub);
        case 'simplex'
            [fitparam,stderr]=get_fit_params_using_simplex(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),parameters,lb,ub);
        case 'simplex_lin_combi'    
            [fitparam,stderr]=get_fit_params_using_simplex_lin_combi(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),parameters,lb,ub);
        case 'genetic'
            [fitparam,stderr]=get_fit_params_using_genetics(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),parameters,lb,ub);
        case 'pattern_search'
            [fitparam,stderr]=get_fit_params_using_pattern_search(spec_measured(ind)-spec_calc(ind),massaxis(ind),molecules(involved),parameters,lb,ub);
    end
    
    %update calculated spec
    spec_calc=spec_calc+multispecparameters(massaxis,molecules(i),fitparam([1,end-1,end]));
    
    k=1;
    for j=involved
        molecules(j).area=fitparam(k); %read out fitted areas for every molecule
        molecules(j).areaerror=stderr(k); %read out fitted areas for every molecule
        k=k+1;
    end
    
    waitbar(i/l);
end
fprintf('Done.\n')
close(h);

out=molecules;

end

