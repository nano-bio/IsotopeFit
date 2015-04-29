function out = fitranges(peakdata,ranges,calibration,areaup,deltares,deltam,fitting_method)
    %out = fitranges(peakdata,ranges)
    %   fits molecules organized in ranges to peakdata
    %   fits area, resolution and massoffset

    massaxis=peakdata(:,1)';
    spec_measured=peakdata(:,2)';

    l=length(ranges);

    %check if there are too many molecules per range
    maxmolperrange=1;
    for i=1:l
        maxmolperrange=max(length(ranges(i).molecules),maxmolperrange);
    end

    if maxmolperrange>200
        choice = questdlg(sprintf('At least in one range, there are more then 200 molecules (max: %i). Do you want to continue?',maxmolperrange), ...
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
%     if matlabpool('size')==0 %check if pool is already open
%         parpool(feature('numcores'))
%     end

    % we use a copy of the original ranges variable,
    % because parfor cannot access the original one! 
    rangestemp=ranges;

    %try to fit more often, when maximum number of function evaluations or 
    %iterations was reached.
    maxruns=10;

    
    
    t_start=tic;
    show_wb=0;
    
    fprintf('Start fitting %i ranges using %s\n',l, fitting_method);
    
    searchrange=3;
    
    %parfor i=1:l
    for i=1:l %use this for patternsearch
        nmolecules=length(ranges(i).molecules);
        
        %maximally used datapoints for fitting per molecule
        maxdatapoints=50*nmolecules;
        
        parameters=zeros(1,nmolecules+2);
        fprintf('%i/%i (%5.1f - %5.1f): %i molecules\r',i,l, ranges(i).minmass,ranges(i).maxmass,nmolecules);

        %ind=findmassrange(massaxis,ranges(i).molecules,ranges(i).resolution,ranges(i).massoffset,10);
        ind=findmassrange2(massaxis,ranges(i).molecules,ranges(i).resolution,ranges(i).massoffset,searchrange);

        %is it necessary to cut out some datapoints?
        ndp=length(ind); %number of datapoints
        if ndp>maxdatapoints %then cut out some datapoints
            ind=ind(round((1:maxdatapoints)*(ndp/maxdatapoints)));%ind will be maxdatapoints long
        end

        for j=1:nmolecules
            if ranges(i).molecules(j).area==0 %dirty workaround: when area=0, no fitting. dont know why!
                parameters(j)=0.1;
            else
                parameters(j)=ranges(i).molecules(j).area;
            end
            parameters(j)=max(0,sum(peakdata(ind,2).*[0;diff(peakdata(ind,1))]));%integrate over peak to estimate area
        end

        parameters(nmolecules+1)=ranges(i).resolution; %resolution
        parameters(nmolecules+2)=ranges(i).massoffset; %x-offset

        drawnow;

        %define upper and lower bound for fitting process:
        lb=[zeros(1,length(parameters)-2),parameters(end-1)-parameters(end-1)*deltares, parameters(end)-deltam];
        ub=[ones(1,length(parameters)-2)*areaup,parameters(end-1)+parameters(end-1)*deltares, parameters(end)+deltam];
        
        switch fitting_method
            case 'linear_system'
                [fitparam,stderr]=get_fit_params_using_linear_system(spec_measured(ind),massaxis(ind),calibration.shape,ranges(i).molecules,parameters,lb,ub);
            case 'simplex'    
                [fitparam,stderr]=get_fit_params_using_simplex(spec_measured(ind),massaxis(ind),calibration.shape,ranges(i).molecules,parameters,lb,ub);
            case 'simplex_lin_combi'    
                [fitparam,stderr]=get_fit_params_using_simplex_lin_combi(spec_measured(ind),massaxis(ind),calibration.shape,ranges(i).molecules,parameters,lb,ub);
            case 'genetic'
                [fitparam,stderr]=get_fit_params_using_genetics(spec_measured(ind),massaxis(ind),calibration.shape,ranges(i).molecules,parameters,lb,ub);
            case 'pattern_search'
                [fitparam,stderr]=get_fit_params_using_pattern_search(spec_measured(ind),massaxis(ind),calibration.shape,ranges(i).molecules,parameters,lb,ub);
        end
       
        % write fitparameters to molecules structure
        for j=1:nmolecules
            rangestemp(i).molecules(j).area=fitparam(j); %read out fitted areas for every molecule
            rangestemp(i).molecules(j).areaerror=stderr(j); %read out fitted areas for every molecule
        end

        rangestemp(i).massoffset=fitparam(end);
        rangestemp(i).resolution=fitparam(end-1);
        rangestemp(i).massoffseterror=stderr(end);
        rangestemp(i).resolutionerror=stderr(end-1);
        
        if ~show_wb
            if toc(t_start)>0.5
                h = waitbar(0,'Please wait...'); 
                show_wb=1;
            end
        else
            waitbar(i/l); %only possible for patternsearch
        end
    end
    if show_wb
        close(h);
    end
    fprintf('Done.\n')

    %center of mass of ranges needs to be recalculated due to different areas
    %of involved molecules:
    out=calccomofranges(rangestemp);

end

