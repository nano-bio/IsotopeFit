function out = multispec(molecules,resolutionaxis,massoffsetaxis,massaxis,shape)
    %out= multispec(molecules,resolution,massoffset,massaxis)
    %   calculates isotopic pattern for molecules in list
    %   uses area stored in molecules structure
    %   DONT use this for fitting!

    spec_calc=zeros(1,length(massaxis));

    % number of molecules to be calculated
    nmol = length(molecules);
    
    % set a number from which on we should do it parallel
    nmolmax = 400;

    show_waitbar = 0;

    % if less than 100 molecules, we do it unparallalized
    if nmol < nmolmax
        tstart=tic;
        for i=1:length(molecules)
            spec_calc=spec_calc+pattern(molecules(i),molecules(i).area,resolutionaxis,massoffsetaxis,massaxis,shape);

            if show_waitbar==1
               waitbar(i/length(molecules));
            end

            if toc(tstart)>0.5 && show_waitbar==0
               h = waitbar(0,'Please wait...');
               show_waitbar=1;
            end
        end
    elseif nmol >= nmolmax % more than 100
        % first check if there is a pool
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(poolobj)
            infobox = msgbox('Hang tight. We are dealing with a lot of molecules. I am setting up a parallel pool. This will speed up things.');
            parpool;
            delete(infobox);
        end
        
        infobox = msgbox('This is running parallel, I cannot show a progress bar. Please wait.');
        parfor i=1:length(molecules)
            spec_calc=spec_calc+pattern(molecules(i),molecules(i).area,resolutionaxis,massoffsetaxis,massaxis,shape);
        end
        delete(infobox);
    end


    if show_waitbar == 1
        close(h);
    end

    out=spec_calc;
end

