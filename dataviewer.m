function dataaxes = dataviewer(parobj, posext, xfatness, yfatness, datasliderbool, callbackfcn)
    % This function draws a complete set of axes including buttons for view
    % adjustments around it. It expects 5 arguments:
    % parobj = the parent object where to drin in (e.g. Parent in most
    % cases)
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
        'NextPlot','replacechildren',...
        'Units','normalized',...
        'Position',alignelements(posext, 3, subgridx, 3, subgridy, 0.01, 0.02));
    
    dataaxes.updateslider = @updateslider;
    dataaxes.getclickcoordinates = @getclickcoordinates;
    
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

    % ===== FUNCTIONS TO CHANGE VIEW ===== %

    function togglelogscale(hObject, ~)
        % This button toggles the logarithmic display of the data axes in
        % y-direction.

        % get settings
        handles = guidata(hObject);

        % turn warning about negative values off
        warning('off', 'MATLAB:Axes:NegativeDataInLogAxis')

        % toggle function
        if (get(hObject,'Value') == get(hObject,'Max'))
            set(dataaxes.axes, 'YScale', 'log');
            handles.status.logscale = 1;
        elseif (get(hObject,'Value') == get(hObject,'Min'))
            set(dataaxes.axes, 'YScale', 'linear');
            handles.status.logscale = 0;
        end

        % save back
        guidata(hObject,handles);
    end

    function doubleyscale(hObject, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(dataaxes.axes, 'YLim');
        % multiply
        nl = [cl(1)*2 cl(2)*2];
        % set back
        set(dataaxes.axes, 'YLim', nl)
    end

    function doublexscale(Parent, ~)
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

    function halfyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(dataaxes.axes, 'YLim');
        % divide
        nl = [cl(1)/2 cl(2)/2];
        % set back
        set(dataaxes.axes, 'YLim', nl)
    end

    function halfxscale(Parent, ~)
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

    function autoyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(dataaxes.axes, 'YLimMode', 'auto');
    end

    function autoxscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(dataaxes.axes, 'XLimMode', 'auto');
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

    function slidedataaxes(hObject, ~)
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
%         axesHandle  = get(hObject,'Parent');
        
        % this gives absolute coordinates within _the window_ -> we have to
        % convert to axes-units
               
%         coordinates = get(axesHandle,'CurrentPoint')
%         areaaxespos = get(hObject, 'Position');
%         xlim = get(hObject, 'XLim');
%         ylim = get(hObject, 'YLim');
%         x = xlim(1) + (xlim(2)-xlim(1))/areaaxespos(3)*(coordinates(1)-areaaxespos(1));
%         y = ylim(1) + (ylim(2)-ylim(1))/areaaxespos(4)*(coordinates(2)-areaaxespos(2));

        % Strange: but this seems to work:
        coordinates=get(hObject,'CurrentPoint');
        x=coordinates(1,1);
        y=coordinates(1,2);
        mouseside=get(gcf,'SelectionType');
    end
end