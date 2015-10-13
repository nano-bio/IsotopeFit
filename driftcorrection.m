function handles = driftcorrection(handles, listindices)
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
      
    % load file
    if isfield(handles.fileinfo,'h5completepath')
        if exist(handles.fileinfo.h5completepath,'file')
            fn = handles.fileinfo.h5completepath;
        else
            choices = questdlg('h5-File not found. Do you want to select one?', 'Select file?', 'Yes', 'No', 'No');
            switch choices
                case 'Yes'
                    [filename, pathname, ~] = uigetfile({'*.h5','HDF5 data file (*.h5)';});
                    fn = fullfile(pathname,filename);
                    handles.fileinfo.h5completepath = fn;
                case 'No'
                    delete(Parent);
                    return;
            end
        end
    else
        choices = questdlg('No original h5-File is known. Do you want to select one?', 'Select file?', 'Yes', 'No', 'No');
        switch choices
            case 'Yes'
                [filename, pathname, ~] = uigetfile({'*.h5','HDF5 data file (*.h5)';});
                fn = fullfile(pathname,filename);
                handles.fileinfo.h5completepath = fn;
            case 'No'
                delete(Parent);
                return;
        end
    end
      
    %ask settings
    prompt = {'Start mass (avoid Schaltpeak):','End mass','Number of divisions:'};
    dlg_title = 'Drift correction parameters';
    num_lines = 1;
    def = {'5','inf','4'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    startmass=str2double(answer{1}); %datapoints below this value will be ignored
    endmass=str2double(answer{2});
    nod=str2double(answer{3});
    
    if endmass>handles.raw_peakdata(end,1)
        endmass=handles.raw_peakdata(end,1);
    end
    
    startindex=mass2ind(handles.raw_peakdata(:,1),startmass);
    endindex=mass2ind(handles.raw_peakdata(:,1),endmass);
    
    % search for largest peak in each division to find center-indices for
    % driftcorrection
    for i=1:nod
%         [~, handles.calibration.dc.centerindex(i)]=...
%             max(handles.raw_peakdata(round(startindex+searchrange+(endindex-startindex)/nod*(i-1)):...
%                                  round(startindex-searchrange+(endindex-startindex)/nod*(i)),2));
%        handles.calibration.dc.centerindex(i)=handles.calibration.dc.centerindex(i)+...
%            round(startindex+searchrange+(endindex-startindex)/nod*(i-1));
%            
%        handles.calibration.dc.minindex(i)=handles.calibration.dc.centerindex(i)-searchrange;
%        handles.calibration.dc.maxindex(i)=handles.calibration.dc.centerindex(i)+searchrange;

       handles.calibration.dc.minindex(i)=round(startindex+(endindex-startindex)/nod*(i-1));
       handles.calibration.dc.maxindex(i)=round(startindex+(endindex-startindex)/nod*i);
       handles.calibration.dc.centerindex(i)=round((handles.calibration.dc.minindex(i)+handles.calibration.dc.maxindex(i))/2);
    end
    
    
    % how broad should one single plot be?
    widthpermol = floor(64/nod);

    % we create one axis for each molecule selected
    for i=1:nod
        peakaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,64,40,64,(i-1)*widthpermol+1,i*widthpermol+1,0.01,0.00));
        
        dcaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,64,23,40,(i-1)*widthpermol+1,i*widthpermol+1,0.01,0.00));
    end
    

    % how big is our data?
    bufs = getnumberofinstancesinh5(fn, 'buffers');
    writes = getnumberofinstancesinh5(fn, 'writes');
    mslength = getnumberofinstancesinh5(fn, 'timebins');
    
    handles.calibration.dc.shifts = zeros(nod, writes-1);
    handles.calibration.dc.shiftweights = zeros(nod, writes-1);
     
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
    for i=1:nod
        plot(peakaxes{i},(handles.calibration.dc.minindex(i):handles.calibration.dc.maxindex(i)), sumdata(handles.calibration.dc.minindex(i):handles.calibration.dc.maxindex(i), 1));
        title(sprintf('Div %i',i))
    end
    
    % calculate the shifts for each molecule
    for i=1:nod
        calcmolshift(i);
    end
    
    % calculate cumulative sum of shifts
    handles.calibration.dc.shifts=cumsum(handles.calibration.dc.shifts,2);
    
    % now we fit a polynomial over the massrange for each write
    fitmolshifts;
    
    % hit slidetimeaxis, so we plot everything
    slidetimeaxes('', '');
    
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
        for i=1:nod
            plot(peakaxes{i}, (handles.calibration.dc.minindex(i):handles.calibration.dc.maxindex(i)), sumdata(handles.calibration.dc.minindex(i):handles.calibration.dc.maxindex(i), current_write))
            title(peakaxes{i}, sprintf('Div. %i',i))
            
            % mark the current write
            try
                set(handles.writeindication{i}, 'XData', current_write, 'YData', handles.calibration.dc.shifts(i, current_write));
            end
        end
        
        % we can also update the massaxes if everything is already
        % calculated
        try
            plot(massaxes, handles.calibration.dc.coms, handles.calibration.dc.shifts(:, current_write), 'ro')

            % for plotting the polynomial we need more points than just writes
            massaxis = linspace(1, max(handles.calibration.dc.coms), max(handles.calibration.dc.coms));
            out = polyval(handles.calibration.dc.shiftpolynoms{current_write}, massaxis);
            
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
        molwidth = handles.calibration.dc.maxindex(molindex) - handles.calibration.dc.minindex(molindex);
        
        % initialize waitbar
        h = waitbar(0, ['Computing shift for each write for ', sprintf('Div %i',molindex), '...']);
        
        % go through every write
        for w=1:writes-1
            %values = zeros(molwidth*2+1,1);
            
            % we cross correlate the signal with the signal of the next write
            s2=sumdata(handles.calibration.dc.minindex(molindex):handles.calibration.dc.maxindex(molindex), w+1);
            s1=sumdata(handles.calibration.dc.minindex(molindex):handles.calibration.dc.maxindex(molindex), w);
            values=ifftshift(ifft(fft(s1(end:-1:1)).*fft(s2)));
            values=values(end:-1:1);
            
%             for j=-molwidth:molwidth
%                 dist = sumdata(handles.molecules(listindices(molindex)).minind+j:handles.molecules(listindices(molindex)).maxind+j, w+1) - sumdata(handles.molecules(listindices(molindex)).minind:handles.molecules(listindices(molindex)).maxind, w);
%                 dist = dist.^2;
%                 values(j+molwidth+1) = sum(dist);
%             end
%             
%             % the minimum is the shift, where it fits the best
%             [val, ind] = min(values);
%plot(values)
            % the maximum cross correlation is the shift
            temp=length(values);
            
            shiftsearch=10;
            
            [handles.calibration.dc.shiftweights(molindex, w), ind] = max(values(round(temp/2-shiftsearch):round(temp/2+shiftsearch)));
            ind=ind+round(temp/2-shiftsearch)-1;
            handles.calibration.dc.shifts(molindex, w) = ind - ceil(molwidth/2)-1;
            
%             p=polyfit(round(temp/2-shiftsearch):round(temp/2+shiftsearch),values(round(temp/2-shiftsearch):round(temp/2+shiftsearch))',2);
%             handles.calibration.dc.shifts(molindex, w)=-p(2)/(2*p(1));
%             
            %handles.calibration.dc.shiftweights(molindex, w) = sum(s1); %we use the max height of the signal as weighting factor for fitting
            % update waitbar
            h = waitbar(w/(writes-1), h);
        end
        
        % we don't need the waitbar any more
        close(h)
        
        shiftsum=cumsum(handles.calibration.dc.shifts(molindex, :));
        
        % we plot the shift over time (=writes) in the corresponding axis
        plot(dcaxes{molindex}, shiftsum, 'ro');

        % we indicate the current displayed write
        current_write = str2double(get(writedisplay, 'String'));
        hold(dcaxes{molindex}, 'on')
        handles.writeindication{molindex} = stem(dcaxes{molindex}, current_write,shiftsum(current_write),'g');
        hold(dcaxes{molindex}, 'off')
        
        % as eye-candy, we fit the resulting shifts with a polynomial.
        % first of all we need a linear space with the steps of the writes:
        writeaxis = linspace(1, writes - 1, writes - 1);
        
        % fit witha polynomial of 2nd order
        p = polyfit(writeaxis, shiftsum, 2);
        
        % for plotting the polynomial we need more points than just writes
        % (we use 100, the default of linspace)
        fitaxis = linspace(1, writes - 1);
        out = polyval(p, fitaxis);
        
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
        handles.calibration.dc.coms = [];
        for i=1:nod
            handles.calibration.dc.coms(i) = handles.raw_peakdata(handles.calibration.dc.centerindex(i),1);
        end
        
        % and a list of peak positions in the time domain
        handles.ppt = [];
        for i=1:nod
            handles.ppt = [handles.ppt, handles.calibration.dc.minindex(i)];
        end

        % fit a 2nd order polynom to over the massrange for each write
        for w=1:writes-1
            handles.calibration.dc.shiftpolynoms{w} = wpolyfit2(handles.calibration.dc.coms, handles.calibration.dc.shifts(:, w)', handles.calibration.dc.shiftweights(:, w)');
            handles.calibration.dc.shiftpolynomstime{w} = wpolyfit2(handles.ppt, handles.calibration.dc.shifts(:, w)', handles.calibration.dc.shiftweights(:, w)');
        end
    end
    
    function out=wpolyfit2(x,y,w)
        size(x)
        size(y)
        size(w)
        f=fittype('poly2');

        options=fitoptions('poly2');
        options.Weights=w';
        
        fun=fit(x',y',f,options);
        
        out = [fun.p1 fun.p2 fun.p3];
        %out = [fun.p1 fun.p2]
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
            poly = polyval(handles.calibration.dc.shiftpolynomstime{i}, timeaxis);
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
            handles.raw_peakdata(:,2) = corr_sum_spectrum;
        end

        close(Parent);
        
    end
end