function dataaxes = dataviewer(parobj, tag, posext, xfatness, yfatness, datasliderbool, callbackfcn)
    % This function draws a complete set of axes including buttons for view
    % adjustments around it. It expects 5 arguments:
    % parobj = the parent object where to draw in (e.g. Parent in most
    % cases)
    % tag = string to identify this axes - for example: 'massspecplot1'
    % posext = the position vector in the reference frame of the parent
    % object (just use gridpos as normal)
    % xfatness, yfatness = basically the number of virtual gridlines within
    % these GUI elements. Higher values mean slimmer buttons.
    % datasliderbool: true -> create a slider for the x-axis, false ->
    % create an autozoom button instead
    % callbackfcn = function that handles callbacks from the axes
    subgridx = xfatness;
    subgridy = yfatness;
    
    handles = guidata(parobj);
    
    % we return a struct with two members: the axes handle and the handle
    % to the updateslider function, because we might want to call that from
    % outside this file. this is called object emulation.

    dataaxes.axes = axes('Parent',parobj,...
        'ButtonDownFcn',callbackfcn,...
        'NextPlot','add',...
        'Units','normalized',...
        'Tag', tag,...
        'Position',alignelements(posext, 3, subgridx, 3, subgridy));

    dataaxes.updateslider = @updateslider;
    dataaxes.getclickcoordinates = @getclickcoordinates;
    dataaxes.cplot = @cplot;
    dataaxes.cstem = @cstem;
    
    % add listener for changes in XLim of the data axes -> if the user pans
    % or zooms using the tools in the toolbar we want to know and update
    % the slider accordingly
    
    addlistener(dataaxes.axes, 'XLim', 'PostSet', @axeseventlisteningwrapper);
    
    % ===== GUI ELEMENTS TO CHANGE VIEW IN DATA AXES ===== %
      
    % Toggle log scale for the data axes
    
    uicontrol(parobj,'style','checkbox',...
        'string','Log',...
        'Callback',@togglelogscale,...
        'Value', 0,...
        'Units','normalized',...
        'TooltipString','Toggle log scale',...
        'Position',alignelements(posext, 0, 1, 0, 1));
    
    % Multiply y-axis by a factor of two
    
    uicontrol(parobj,'style','pushbutton',...
        'string','*2',...
        'Callback',@doubleyscale,...
        'Units','normalized',...
        'TooltipString','Multiply axes by a factor of two',...
        'Position',alignelements(posext, 0, 1, subgridy-1, subgridy));
    
    % Divide y-axis by a factor of two
    
    uicontrol(parobj,'style','pushbutton',...
        'string','/2',...
        'Callback',@halfyscale,...
        'Units','normalized',...
        'TooltipString','Divide axes by a factor of two',...
        'Position',alignelements(posext, 0, 1, 2, 3));
    
    % Autoscale y-axis
    
    uicontrol(parobj,'style','pushbutton',...
        'string','Y',...
        'Callback',@autoyscale,...
        'Units','normalized',...
        'TooltipString','Autoscale axes',...
        'Position',alignelements(posext, 0, 1, 4, subgridy-2));
    
    % Divide x-axis by a factor of two
    
    uicontrol(parobj,'style','pushbutton',...
        'string','/2',...
        'Callback',@halfxscale,...
        'Units','normalized',...
        'TooltipString','Multiply axes by a factor of two',...
        'Position',alignelements(posext, 2, 3, 0, 1));
    
    % Multiply x-axis by a factor of two
    
    uicontrol(parobj,'style','pushbutton',...
        'string','*2',...
        'Callback',@doublexscale,...
        'Units','normalized',...
        'TooltipString','Divide axes by a factor of two',...
        'Position',alignelements(posext, subgridx-1, subgridx, 0, 1));
    
    % slider x-axis
    if datasliderbool
        dataxslider = uicontrol(parobj,'style','slider',...
            'string','/2',...
            'Callback',@slidedataaxes,...
            'Units','normalized',...
            'TooltipString','Slide along the mass spec',...
            'Position',alignelements(posext, 4, subgridx-2, 0, 1));
    else
        % Autoscale x-axis
        
        uicontrol(parobj,'style','pushbutton',...
            'string','X',...
            'Callback',@autoxscale,...
            'Units','normalized',...
            'TooltipString','Autoscale axes',...
            'Position',alignelements(posext, 4, subgridx-2, 0, 1));
    end
    
    % ===== POSITIONING FUNCTION ===== %
    
    function posvec = alignelements(posext, lindex, rindex, bindex, tindex, borderx, bordery)
        % this is a wrapper for the famous gridpos. it adds the additional
        % complexity of using an external position vector. everything is
        % placed with gridpos within the given external rectangle.
        % posext = external position vector
        % lindex, rindex = left and right indices in the coordinate system
        % defined by subgridx/y in the first two lines of this file.
        if nargin < 7
            borderx = 0.00;
            bordery = 0.00;
        end

        posint = gridpos(subgridy, subgridx, bindex, tindex, lindex, rindex, borderx, bordery);
        posvec(1) = posext(1) + posint(1)*posext(3);
        posvec(2) = posext(2) + posint(2)*posext(4);
        posvec(3) = posext(3)*posint(3);
        posvec(4) = posext(4)*posint(4);
    end

    % ===== WRAPPER FOR PLOT FUNCTIONS ===== %
    % we need a wrapper for the plot functions, because the built-in
    % plot-functions destroy all axes properties which is annoying and
    % quite frankly stupid
    
    function cplot(varargin)
        % An extensive comment is due here: We read out the OuterPosition
        % property of the dataaxes object. Later in this function we write
        % it back. Additionally, all other properties are read out and
        % written back. However, OuterPosition seems to change due to a
        % weird bug in Matlab. Hence we write it back individually which
        % seems to work around that bug. This is dirty and I hope no other
        % properties are affected.
        outposproperty = dataaxes.axes.OuterPosition;
        % read all properties
        allproperties = get(dataaxes.axes);
        
        % plot the data
        arguments={dataaxes.axes,varargin{:}};
        plot(arguments{:});
        
        % remove properties that are read-only and cannot be written back
        allproperties = rmfield(allproperties, 'BeingDeleted');
        allproperties = rmfield(allproperties, 'Children');
        allproperties = rmfield(allproperties, 'CurrentPoint');
        allproperties = rmfield(allproperties, 'TightInset');
        allproperties = rmfield(allproperties, 'Type');
        
        % set all properties again
        set(dataaxes.axes, allproperties);
        % write back the outer position as explained above.
        dataaxes.axes.OuterPosition = outposproperty;
    end

    function cstem(varargin)
        % read all properties
        allproperties = get(dataaxes.axes);
        
        % plot the data
        arguments={dataaxes.axes,varargin{:}};
        stem(arguments{:});
        
        % remove properties that are read-only and cannot be written back
        allproperties = rmfield(allproperties, 'BeingDeleted');
        allproperties = rmfield(allproperties, 'Children');
        allproperties = rmfield(allproperties, 'CurrentPoint');
        allproperties = rmfield(allproperties, 'TightInset');
        allproperties = rmfield(allproperties, 'Type');
        
        % set all properties again
        set(dataaxes.axes, allproperties);
    end

    % ===== FUNCTIONS TO CHANGE VIEW ===== %

    function togglelogscale(~, ~)
        % This button toggles the logarithmic display of the data axes in
        % y-direction.
        
        % turn warning about negative values off
        warning('off', 'MATLAB:Axes:NegativeDataInLogAxis')

        % toggle function
        if strcmp(get(dataaxes.axes, 'YScale'),'linear')
            set(dataaxes.axes, 'YScale', 'log');
        else
            set(dataaxes.axes, 'YScale', 'linear');
        end
    end

    function doubleyscale(~, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(dataaxes.axes, 'YLim');
        % multiply
        nl = [cl(1)*2 cl(2)*2];
        % set back
        set(dataaxes.axes, 'YLim', nl)
    end

    function doublexscale(~, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(dataaxes.axes, 'XLim');
        %half width to add
        hw = (cl(2)-cl(1))/2;
        % add
        nl = [cl(1)-hw cl(2)+hw];
        % set back
        set(dataaxes.axes, 'XLim', nl);
        
        updateslider(parobj, 'nothingreally');
    end

    function halfyscale(~, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(dataaxes.axes, 'YLim');
        % divide
        nl = [cl(1)/2 cl(2)/2];
        % set back
        set(dataaxes.axes, 'YLim', nl)
    end

    function halfxscale(~, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(dataaxes.axes, 'XLim');
        % quarter width to add
        hw = (cl(2)-cl(1))/4;
        % add
        nl = [cl(1)+hw cl(2)-hw];
        % set back
        set(dataaxes.axes, 'XLim', nl);
        
        updateslider(parobj, 'nothingreally');
    end

    function autoyscale(~, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(dataaxes.axes, 'YLimMode', 'auto');
    end

    function autoxscale(~, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(dataaxes.axes, 'XLimMode', 'auto');
    end

    function axeseventlisteningwrapper(~, ~)
        % this wrapper has enough arguments to be a callback function.
        % however, we don't need them so they are discarded.
        % this updates the slider every time the user uses zooming or
        % paning from the toolbar
        updateslider(parobj, 'nothingreally');
    end

    function updateslider(hObject, ~)
        % we only need that if we have a slider
        if datasliderbool
            % This function updates the x-axis slider accordingly whenever 
            % something changes in the dataaxes.axes

            % supress warnings in case the user scrolls and pans around in an
            % uncontrolled manner and withour fear of disaster:
            warning('off', 'MATLAB:hg:uicontrol:ParameterValuesMustBeValid');

            % get settings
            handles = guidata(hObject);

            % calculate where around we are centered
            xlims = get(dataaxes.axes, 'XLim');
            com = (xlims(2) + xlims(1))/2;
            viewedrange = xlims(2) - xlims(1);

            % how big is our massspec?
            try
                maxmass = max(handles.peakdata(:,1));
            catch
                maxmass = 1;
            end

            % we should calculate the width of our slider
            slwidth = viewedrange/maxmass;
            % set the max to the maximum mass
            set(dataxslider, 'Max', maxmass);
            % since the Max is our mass range we can set this to the center of
            % mass
            set(dataxslider, 'Value', com);
            % set the slider width
            set(dataxslider, 'SliderStep', [slwidth/10 slwidth])
        end
    end

    function slidedataaxes(~, ~)
        % This function updates the data axes when the slider for the
        % x-axis is clicked
        
        % calculate where around we are centered
        cl = get(dataaxes.axes, 'XLim');
        % we need to add / substract half of the currently viewed range to
        % the new center of mass
        vrhalf = (cl(2) - cl(1))/2;
        
        % get center of mass
        com = get(dataxslider, 'Value');
        
        % new viewing range
        nl = [com-vrhalf com+vrhalf];
        % jump by one view range
        set(dataaxes.axes, 'XLim', nl);
    end

    function [x, y,mouseside]=getclickcoordinates(hObject)
        % this function returns the coordinates of a click in terms of the
        % axes units.

        % Strange: but this seems to work:
        coordinates=get(hObject,'CurrentPoint');
        x=coordinates(1,1);
        y=coordinates(1,2);
        mouseside=get(gcf,'SelectionType');
    end
end