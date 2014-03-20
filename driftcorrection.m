function dcout = driftcorrection(handles, listindices)
    % ===== LAYOUT ===== %

    Parent = figure( ...
        'MenuBar', 'none', ...
        'ToolBar','figure',...
        'NumberTitle', 'off', ...
        'Name', 'Drift correction',...
        'Units','normalized',...
        'Position',[0.4,0.1,0.4,0.8]);

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
    
    uicontrol(Parent,'style','pushbutton',...
          'string','Fit that shit',...
          'Callback',@fitmolecule2,...
          'Units','normalized',...
          'Position',gridpos(64,30,1,4,2,4,0.01,0.01));
      
    uicontrol(Parent,'Style','Text',...
            'String','Current write',...
            'Units','normalized',...
            'Position',gridpos(64,30,32,33,1,3,0.01,0.01));

    writedisplay = uicontrol(Parent,'Style','Text',...
            'String','1',...
            'Units','normalized',...
            'Position',gridpos(64,30,31,32,1,3,0.01,0.01));
    
    nom = length(listindices);

    % we create one axis for each molecule selected
    for i=1:nom
        peakaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,30,33,64,(i-1)*5+1,i*5+1,0.01,0.00));
        
        dcaxes{i} = axes(...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'OuterPosition',gridpos(64,30,3,31,(i-1)*5+1,i*5+1,0.01,0.00));
         
        calcbutton{i} = uicontrol(Parent,'style','pushbutton',...
          'string','Calculate shift',...
          'Callback',{@calcmolshift, i},...
          'Units','normalized',...
          'Position',gridpos(64,30,1,4,(i-1)*5+2,(i-1)*5+3,0.01,0.01));
      
        fitbutton{i} = uicontrol(Parent,'style','pushbutton',...
          'string','Fit shift',...
          'Callback',@fitmol_selector,...
          'Units','normalized',...
          'Position',gridpos(64,30,1,4,(i-1)*5+4,(i-1)*5+5,0.01,0.01));
    end
    
    % load file
    fn = fullfile(handles.fileinfo.pathname,handles.fileinfo.originalfilename);
    % preliminary and hard coded until we have the proper h5-filename in
    % the handles
    fn = 'Z:\Experiments\STM\Methanol\D-Meth+C60\DataFile_2012.04.07-02h20m55s_AS.h5';

    % how big is our data?
    fileinfo = h5info(fn, '/FullSpectra/TofData');
    sizes = fileinfo.Dataspace.Size;

    bufs = sizes(3);
    writes = sizes(4);
    mslength = sizes(1);
    
    handles.shifts = zeros(nom, writes-1);
    
    % average all buffers in each write
    avgdata = average_write(writes, mslength);
    
    % now that we know how many writes we have, we can create the slider
    timeslider = uicontrol(Parent,'style','slider',...
          'Callback',@slidetimeaxes,...
          'Units','normalized',...
          'TooltipString','Slide through the writes',...
          'Max',writes,...
          'Min',1,...
          'Value',1,...
          'SliderStep',[1/(writes) 1/(writes)],...
          'Position',gridpos(64,30,31,33,4,30,0.01,0.01));

    % let's plot each peak
    for i=1:nom
        plot(peakaxes{i},(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind), avgdata(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind, 1));
        title(handles.molecules{listindices(i)}.name)
    end
    dcout = 0
    
    % ===== GUI FUNCTIONS ===== %
    
    function slidetimeaxes(hObject, eventdata)
        %handles = guidata(Parent);
        % This function updates all the plots when the time (= writes)
        % slider is clicked
        
        % which write shall we display?
        % we have to floor that anyway, because even if the slider step is
        % set to integer values, one can drag the slider to any position
        current_write = floor(get(timeslider, 'Value'));
        
        % plot it
        for i=1:nom
            plot(peakaxes{i}, (handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind), avgdata(handles.molecules{listindices(i)}.minind:handles.molecules{listindices(i)}.maxind, current_write))
            title(peakaxes{i}, handles.molecules{listindices(i)}.name)
            
            % mark the current write
            try
                set(handles.writeindication{i}, 'XData', current_write, 'YData', handles.shifts(i, current_write));
            end
        end
        
        % display the current write number
        set(writedisplay, 'String', current_write);

    end
    
    % ===== INTERNAL FUNCTIONS ===== %
    
    function avgs = average_write(writes, mslength)
        % create an empty cell
        avgs = zeros(mslength, writes);
        h = waitbar(0, 'Computing averages for writes...');
        
        for i=1:writes
            h = waitbar(i/writes, h);
            % just read all the bufs in that write, because more would be
            % too memory consuming
            data = h5read(fn, '/FullSpectra/TofData', [1 1 1 i], [mslength 1 bufs 1]);
            
            % average along the third dimension (bufs)
            avgs(:, i) = mean(data, 3);
        end
        close(h)
        return
    end

    function calcmolshift(src,eventdata, molindex)
        % how broad is our molecule?
        molwidth = handles.molecules{listindices(molindex)}.maxind - handles.molecules{listindices(molindex)}.minind;
        
        % initialize waitbar
        h = waitbar(0, 'Computing shift for each write...');
        
        % go through every write
        for w=1:writes-1
            values = zeros(molwidth*2+1,1);
            
            % we "convolute" the signal with the signal of the next write
            for j=-molwidth:molwidth
                dist = avgdata(handles.molecules{listindices(molindex)}.minind+j:handles.molecules{listindices(molindex)}.maxind+j, w+1) - avgdata(handles.molecules{listindices(molindex)}.minind:handles.molecules{listindices(molindex)}.maxind, w);
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
        current_write = str2num(get(writedisplay, 'String'));
        hold(dcaxes{molindex}, 'on')
        handles.writeindication{molindex} = stem(dcaxes{molindex}, current_write, handles.shifts(molindex, current_write),'g');
        hold(dcaxes{molindex}, 'off')
    end
end