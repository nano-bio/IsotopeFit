function dcout = driftcorrection(handles, listindices)
    % ===== LAYOUT ===== %

    Parent = figure( ...
        'MenuBar', 'none', ...
        'ToolBar','figure',...
        'NumberTitle', 'off', ...
        'Name', 'Drift correction',...
        'Units','normalized',...
        'OuterPosition', [0, 0, 1, 1]);

    %remove unused tools:
    hTemp = findall(Parent,'tag','Plottools.PlottoolsOn');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Plottools.PlottoolsOff');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Annotation.InsertLegend');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Annotation.InsertColorbar');
    delete(hTemp);
    hTemp = findall(Parent,'tag','DataManager.Linking');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Exploration.Brushing');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Standard.EditPlot');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Standard.PrintFigure');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Standard.NewFigure');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Exploration.Rotate');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Standard.FileOpen');
    delete(hTemp);
    hTemp = findall(Parent,'tag','Standard.SaveFigure');
    delete(hTemp);
      
    uicontrol(Parent,'Style','Text',...
            'String','Current write',...
            'Units','normalized',...
            'Position',gridpos(64,30,21,23,1,3,0.01,0.01));

    writedisplay = uicontrol(Parent,'Style','Text',...
            'String','1',...
            'Units','normalized',...
            'Position',gridpos(64,30,21,23,3,4,0.01,0.01));
        
    massaxes = axes(...
         'ButtonDownFcn','disp(''axis callback'')',...
         'Units','normalized',...
         'OuterPosition',gridpos(64,64,3,21,1,64,0.00,0.01));
     
    uicontrol(Parent,'style','pushbutton',...
          'string','Correct shift',...
          'Callback',@correctshift,...
          'Units','normalized',...
          'Position',gridpos(64,64,1,3,1,64,0.01,0.01));
    
    nom = length(listindices);
    
    % how broad should one single plot be?
    widthpermol = floor(64/nom);

    % we create one axis for each molecule selected
    for i=1:nom
        peakaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,64,40,64,(i-1)*widthpermol+1,i*widthpermol+1,0.01,0.00));
        
        dcaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,64,23,40,(i-1)*widthpermol+1,i*widthpermol+1,0.01,0.00));
    end
    
    % load file
    fn = handles.fileinfo.h5completepath;

    % how big is our data?
    fileinfo = h5info(fn, '/FullSpectra/TofData');
    sizes = fileinfo.Dataspace.Size;

    bufs = sizes(3);
    writes = sizes(4);
    mslength = sizes(1);
    
    handles.shifts = zeros(nom, writes-1);
    
    % sum all buffers in each write
    sumdata = sum_writes(writes, mslength);
    
    % now that we know how many writes we have, we can create the slider
    timeslider = uicontrol(Parent,'style','slider',...
          'Callback',@slidetimeaxes,...
          'Units','normalized',...
          'TooltipString','Slide through the writes',...
          'Max',writes-1,...
          'Min',1,...
          'Value',1,...
          'SliderStep',[1/(writes-1) 1/(writes-1)],...
          'Position',gridpos(64,30,21,23,4,30,0.01,0.01));

    % let's plot each peak
    for i=1:nom
        plot(peakaxes{i},(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind), sumdata(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind, 1));
        title(handles.molecules{listindices(i)}.name)
    end
    
    % calculate the shifts for each molecule
    for i=1:nom
        calcmolshift(i);
    end
    
    % now we fit a polynomial over the massrange for each write
    fitmolshifts;
    
    % hit slidetimeaxis, so we plot everything
    slidetimeaxes('', '');
    
    dcout = 0;
    
    % ===== GUI FUNCTIONS ===== %
    
    function slidetimeaxes(~, ~)
        %handles = guidata(Parent);
        % This function updates all the plots when the time (= writes)
        % slider is clicked
        
        % which write shall we display?
        % we have to floor that anyway, because even if the slider step is
        % set to integer values, one can drag the slider to any position
        current_write = floor(get(timeslider, 'Value'));
        
        % plot it
        for i=1:nom
            plot(peakaxes{i}, (handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind), sumdata(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind, current_write))
            title(peakaxes{i}, handles.molecules{listindices(i)}.name)
            
            % mark the current write
            try
                set(handles.writeindication{i}, 'XData', current_write, 'YData', handles.shifts(i, current_write));
            end
        end
        
        % we can also update the massaxes if everything is already
        % calculated
        try
            plot(massaxes, handles.coms, handles.shifts(:, current_write), 'ro')

            % for plotting the polynomial we need more points than just writes
            massaxis = linspace(1, max(handles.coms), max(handles.coms));
            out = polynomial(handles.shiftpolynoms{current_write}, massaxis);
            
            % instead of a polynom we need a funcation that gives integer
            % steps to correct by. we show that too.
            roundedpoly = round(out);

            % now we are ready to plot
            hold(massaxes, 'on')
            plot(massaxes,massaxis,out,'k--');
            plot(massaxes,massaxis,roundedpoly,'g--');
            hold(massaxes, 'off')
        end
        
        % display the current write number
        set(writedisplay, 'String', current_write);

    end
    
    % ===== INTERNAL FUNCTIONS ===== %
    
    function sums = sum_writes(writes, mslength)
        % create an empty cell
        sums = zeros(mslength, writes);
        h = waitbar(0, 'Computing sums for writes...');
        
        for i=1:writes
            h = waitbar(i/writes, h);
            % just read all the bufs in that write, because more would be
            % too memory consuming
            data = h5read(fn, '/FullSpectra/TofData', [1 1 1 i], [mslength 1 bufs 1]);
            
            % sum up along the third dimension (bufs)
            sums(:, i) = sum(data, 3);
        end
        close(h)
        return
    end

    function calcmolshift(molindex)
        % how broad is our molecule?
        molwidth = handles.molecules{listindices(molindex)}.maxind - handles.molecules{listindices(molindex)}.minind;
        
        % initialize waitbar
        h = waitbar(0, ['Computing shift for each write for ', handles.molecules{listindices(molindex)}.name, '...']);
        
        % go through every write
        for w=1:writes-1
            values = zeros(molwidth*2+1,1);
            
            % we "convolute" the signal with the signal of the next write
            for j=-molwidth:molwidth
                dist = sumdata(handles.molecules{listindices(molindex)}.minind+j:handles.molecules{listindices(molindex)}.maxind+j, w+1) - sumdata(handles.molecules{listindices(molindex)}.minind:handles.molecules{listindices(molindex)}.maxind, w);
                dist = dist.^2;
                values(j+molwidth+1) = sum(dist);
            end
            
            % the minimum is the shift, where it fits the best
            [val, ind] = min(values);
            handles.shifts(molindex, w) = ind - molwidth - 1;
            
            % update waitbar
            h = waitbar(w/(writes-1), h);
        end
        
        % we don't need the waitbar any more
        close(h)
        
        % we plot the shift over time (=writes) in the corresponding axis
        plot(dcaxes{molindex}, handles.shifts(molindex, :), 'ro');

        % we indicate the current displayed write
        current_write = str2double(get(writedisplay, 'String'));
        hold(dcaxes{molindex}, 'on')
        handles.writeindication{molindex} = stem(dcaxes{molindex}, current_write, handles.shifts(molindex, current_write),'g');
        hold(dcaxes{molindex}, 'off')
        
        % as eye-candy, we fit the resulting shifts with a polynomial.
        % first of all we need a linear space with the steps of the writes:
        writeaxis = linspace(1, writes - 1, writes - 1);
        
        % fit witha polynomial of 2nd order
        p = polyfit(writeaxis, handles.shifts(molindex, :), 2);
        
        % for plotting the polynomial we need more points than just writes
        % (we use 100, the default of linspace)
        fitaxis = linspace(1, writes - 1);
        out = polynomial(p, fitaxis);
        
        % now we are ready to plot
        hold(dcaxes{molindex}, 'on')
        plot(dcaxes{molindex},fitaxis,out,'k--');
        hold(dcaxes{molindex}, 'off')
    end

    function fitmolshifts()
        % this fits polynoms over the massrange for each write, using the
        % calculated shifts. additionally it does the same in the time
        % domain (because that is what is actually corrected
        
        % we need a list of centers of masses
        handles.coms = [];
        for i=1:nom
            handles.coms = [handles.coms, handles.molecules{listindices(i)}.com];
        end
        
        % and a list of peak positions in the time domain
        handles.ppt = [];
        for i=1:nom
            handles.ppt = [handles.ppt, handles.molecules{listindices(i)}.minind];
        end

        % fit a 2nd order polynom to over the massrange for each write
        for w=1:writes-1
            handles.shiftpolynoms{w} = polyfit(handles.coms, handles.shifts(:, w)', 2);
            handles.shiftpolynomstime{w} = polyfit(handles.ppt, handles.shifts(:, w)', 2);
        end
    end

    function correctshift(hObject, eventdata)
        % start up a waitbar
        h = waitbar(0, 'Correcting shift...');
        
        % create a timeaxis. we can safely assume it's the same length in
        % every write
        s = size(sumdata(:, 1));
        timeaxis = linspace(1, s(1), s(1));
        
        % empty vector to hold the corrected data
        corr_sum_spectrum = zeros('like', sumdata(:, 1));
        
        % loop through writes
        for i = 1:writes-1
            % write the polynom over the timeaxis (as opposed to mass axis
            % used in the plots)
            poly = polynomial(handles.shiftpolynomstime{i}, timeaxis);
            stepfunc = round(poly);
            
            % this is tricky: we set the first n datapoints to 0, where n
            % is the function value of the correction function in position
            % 1. this prevents indicides out of bound. as long as the
            % fitted function is continuous this works. same procedure for
            % the end.
            stepfunc(1:abs(stepfunc(1))) = 0;
            stepfunc(size(stepfunc, 2)-stepfunc(end):size(stepfunc, 2)) = 0;
            
            % now sum them up.
            corr_sum_spectrum = corr_sum_spectrum + sumdata(timeaxis+stepfunc, i);
            
            % update waitbar
            waitbar(i/(writes-1), h);
        end
        
        % close waitbar
        close(h);
        
        % retrieve position of current window
        pos = get(Parent, 'OuterPosition');
        
        % we read the SumSpectrum from the file in order to visually
        % compare.
        signal = h5read(fn,'/FullSpectra/SumSpectrum');
        
        % show a comparison window and wait for the answer
        ok = comp_ms(signal, corr_sum_spectrum, timeaxis, pos);
        
        % we either return the uncorrected or the corrected spectrum
        if ok
            dcout = corr_sum_spectrum;
        else
            dcout = signal;
        end
        close(Parent);
        
    end
end