function [bgcorrectionout, startind, endind] = bg_correction(peakdata,bgcorrectiondata)

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

layoutlines=11;
layoutrows=5;

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Background correction',...
    'Position',[0.4*scrsz(3),0.4*scrsz(4),0.4*scrsz(3),0.4*scrsz(4)]); 

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
    'Tag','TextStartMass',...
    'String','Start mass',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,11,11,1,1,0.01,0.03));

e_startmass=uicontrol(Parent,'Style','edit',...
    'Tag','edit_startmass',...
    'Units','normalized',...,...
    'String','0',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,11,11,2,2,0.05,0.025));

uicontrol(Parent,'Style','Text',...
    'Tag','TextEndMass',...
    'String','End Mass',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,11,11,4,4,0.01,0.03));

e_endmass=uicontrol(Parent,'Style','edit',...
    'Tag','edit_endmass',...
    'Units','normalized',...,...
    'String','End',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,11,11,5,5,0.05,0.025));

axis1 = axes('Parent',Parent,...
             'ActivePositionProperty','OuterPosition',...
             'Units','normalized',...
             'Position',gridpos(66,60,17,61,4,60,0.04,0.04));
%            'ButtonDownFcn','disp(''axis callback'')',...
        
e_ndiv=uicontrol(Parent,'Style','edit',...
    'Tag','edit_ndiv',...
    'String','10',...
    'Units','normalized',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,1,1,1,1,0.05,0.025));

uicontrol(Parent,'Style','Text',...
    'Tag','Text1',...
    'String','Number of divisions',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,2,2,1,1,0.01,0.03));

e_percent=uicontrol(Parent,'Style','edit',...
    'Tag','edit_npoints',...
    'String','10',...
    'Units','normalized',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,1,1,2,2,0.05,0.025));

uicontrol(Parent,'Style','Text',...
    'Tag','Text2',...
    'String','Evaluation points (%)',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,2,2,2,2,0.01,0.03));

% e_polydegree=uicontrol(Parent,'Style','edit',...
%     'Tag','edit_polydegree',...
%     'Units','normalized',...,...
%     'String','2',...
%     'Background','white',...
%     'Position',gridpos(layoutlines,layoutrows,1,1,3,3,0.05,0.025),...
%     'Callback',@edit1_callback);
% 
% uicontrol(Parent,'Style','Text',...
%     'Tag','Text3',...
%     'String','Polynom degree',...
%     'Units','normalized',...
%     'Position',gridpos(layoutlines,layoutrows,2,2,3,3,0.01,0.03));
         
uicontrol(Parent,'style','pushbutton',...
          'string','Show',...
          'Callback',@show,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,4,4,0.05,0.05)); 

% when OK is pushed uiwait ends 
uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback','uiresume(gcbf)',...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,5,5,0.05,0.05)); 

%Update(Parent);


% ===== GUI ELEMENTS TO CHANGE VIEW IN AXIS1 ===== %
      
% Toggle log scale for the data axes
      
uicontrol(Parent,'style','checkbox',...
          'string','Log',...
          'Callback',@togglelogscale,...
          'Value', 0,...
          'Units','normalized',...
          'TooltipString','Toggle log scale',...
          'Position',gridpos(66,30,13,16,1,2.2,0.01,0.005));
      
% Multiply y-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','*2',...
          'Callback',@doubleyscale,...
          'Units','normalized',...
          'TooltipString','Multiply axes by a factor of two',...
          'Position',gridpos(66,30,55,58,1,2,0.01,0.005));
      
% Divide y-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','/2',...
          'Callback',@halfyscale,...
          'Units','normalized',...
          'TooltipString','Divide axes by a factor of two',...
          'Position',gridpos(66,30,17,20,1,2,0.01,0.005));
      
% Autoscale y-axis
      
uicontrol(Parent,'style','pushbutton',...
          'string','Y',...
          'Callback',@autoyscale,...
          'Units','normalized',...
          'TooltipString','Autoscale axes',...
          'Position',gridpos(66,30,21,54,1,2,0.01,0.005));
      
% Divide x-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','/2',...
          'Callback',@halfxscale,...
          'Units','normalized',...
          'TooltipString','Multiply axes by a factor of two',...
          'Position',gridpos(66,30,13,16,28,29,0.01,0.005));
      
% Multiply x-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','*2',...
          'Callback',@doublexscale,...
          'Units','normalized',...
          'TooltipString','Divide axes by a factor of two',...
          'Position',gridpos(66,30,13,16,3,4,0.01,0.005));
      
% slider x-axis
      
dataxslider = uicontrol(Parent,'style','slider',...
          'string','/2',...
          'Callback',@slidedataaxes,...
          'Units','normalized',...
          'TooltipString','Slide along the mass spec',...
          'Position',gridpos(66,30,13,16,5,27,0.01,0.005));
      
% Plot overview
      
uicontrol(Parent,'style','pushbutton',...
          'string','OV',...
          'Callback',@plotoverview,...
          'Units','normalized',...
          'TooltipString','Plot whole mass spec (overview)',...
          'Position',gridpos(66,30,59,62,1,2,0.01,0.005));



% ############################## END OF LAYOUT


%A=load(file);
handles=guidata(Parent);

handles.massaxis = peakdata(:,1)';
handles.signal = peakdata(:,2)'; 
handles.bgdata = zeros(1,size(peakdata,1));

handles.bgcorrectiondata=bgcorrectiondata;

handles.startup = 1;

set(e_startmass,'String',num2str(bgcorrectiondata.startmass));
set(e_endmass,'String',num2str(bgcorrectiondata.endmass));
set(e_ndiv,'String',num2str(bgcorrectiondata.ndiv));
%set(e_polydegree,'String',num2str(bgcorrectiondata.polydegree));
set(e_percent,'String',num2str(bgcorrectiondata.percent));


% Abspeichern der Struktur 
guidata(Parent,handles); 

show(Parent,0);

    function show(hObject, ~)
        handles=guidata(hObject);
        handles.bgcorrectiondata.ndiv=str2num(get(e_ndiv,'String'));
        handles.bgcorrectiondata.percent=str2num(get(e_percent,'String'));
        %handles.bgcorrectiondata.polydegree=str2num(get(e_polydegree,'String'));
        
        % retrieve current view settings from axes:
        if (handles.startup == 0) % only if we're not starting up any more...
            xlim = get(axis1, 'XLim');
            ylim = get(axis1, 'YLim');
        end
        
        % get numeric values for start and end mass from edit
        temp=get(e_startmass,'String');
        if strcmp(temp,'start')
            handles.bgcorrectiondata.startmass=-inf;
        else
            handles.bgcorrectiondata.startmass=str2double(temp);
        end
        
        temp=get(e_endmass,'String');
        if strcmp(temp,'end')
            handles.bgcorrectiondata.endmass=+inf;
        else
            handles.bgcorrectiondata.endmass=str2double(temp);
        end
        
        % calculates a list of bgr values for a certain number of data points
        % i.e. masses and displays start and end indices for mass axis
        [handles.bgcorrectiondata.bgm,handles.bgcorrectiondata.bgy, handles.startind, handles.endind]=...
            find_bg(handles.massaxis,handles.signal,...
                handles.bgcorrectiondata.ndiv,...
                handles.bgcorrectiondata.percent,...
                handles.bgcorrectiondata.startmass,...
                handles.bgcorrectiondata.endmass);
        
        % crop mass index and axis according to start and end indices
        handles.massaxiscrop=handles.massaxis(handles.startind:handles.endind);
        handles.signalcrop=handles.signal(handles.startind:handles.endind);
        
        % plot spectrum and fitted curve (pchip) between data points of background correction
        plot(axis1,handles.massaxiscrop,handles.signalcrop,handles.massaxiscrop,interp1(handles.bgcorrectiondata.bgm,handles.bgcorrectiondata.bgy,handles.massaxiscrop,'pchip','extrap'));
        
        % reset zoom state to what it was before:
        if (handles.startup == 0)
            set(axis1, 'XLim', xlim)
            set(axis1, 'YLim', ylim)
        end
        
        % now we plotted something and it's definitely not startup conditions
        % any more
        handles.startup = 0;
        
        guidata(hObject,handles);
        
    end


% ====FUNCTIONS NEEDED TO CHANGE VIEW IN AXIS1==== % 

% initialize some status values needed for these functions 
handles.status.logscale = 0;
handles.status.overview = 0;
handles.status.lastlims = [[0 0] [0 0]];
guidata(Parent,handles);

function togglelogscale(hObject, ~)
        % This button toggles the logarithmic display of the data axes in
        % y-direction.
        
        % get settings
        handles = guidata(Parent);
        
        % turn warning about negative values off
        warning('off', 'MATLAB:Axes:NegativeDataInLogAxis')
        
        % toggle function
        if (get(hObject,'Value') == get(hObject,'Max'))
            set(axis1, 'YScale', 'log');
            handles.status.logscale = 1;
        elseif (get(hObject,'Value') == get(hObject,'Min'))
            set(axis1, 'YScale', 'linear');
            handles.status.logscale = 0;
        end
        
        % save back
        guidata(Parent,handles);
    end


    function doubleyscale(hObject, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(axis1, 'YLim');
        % multiply
        nl = [cl(1)*2 cl(2)*2];
        % set back
        set(axis1, 'YLim', nl)
    end

    function doublexscale(hObject, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(axis1, 'XLim');
        %half width to add
        hw = (cl(2)-cl(1))/2;
        % add
        nl = [cl(1)-hw cl(2)+hw];
        % set back
        set(axis1, 'XLim', nl);
        
        updateslider;
    end

    function halfyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(axis1, 'YLim');
        % divide
        nl = [cl(1)/2 cl(2)/2];
        % set back
        set(axis1, 'YLim', nl)
    end

    function halfxscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(axis1, 'XLim');
        % quarter width to add
        hw = (cl(2)-cl(1))/4;
        % add
        nl = [cl(1)+hw cl(2)-hw];
        % set back
        set(axis1, 'XLim', nl);
        
        updateslider;
    end

    function autoyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(axis1, 'YLimMode', 'auto');
    end

    function updateslider(hObject, ~)
        % This function updates the x-axis slider accordingly whenever 
        % something changes in the dataaxes
        
        % supress warnings in case the user scrolls and pans around in an
        % uncontrolled manner and withour fear of disaster:
        warning('off', 'MATLAB:hg:uicontrol:ParameterValuesMustBeValid');
        
        % get settings
        handles = guidata(Parent);
        
        % calculate where around we are centered
        xlims = get(axis1, 'XLim');
        com = (xlims(2) + xlims(1))/2;
        viewedrange = xlims(2) - xlims(1);
        
        % how big is our massspec?
        try
            maxmass = max(handles.massaxiscrop);
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

    function slidedataaxes(hObject, ~)
        % This function updates the data axes when the slider for the
        % x-axis is clicked
        
        % calculate where around we are centered
        cl = get(axis1, 'XLim');
        % we need to add / substract half of the currently viewed range to
        % the new center of mass
        vrhalf = (cl(2) - cl(1))/2;
        
        % get center of mass
        com = get(dataxslider, 'Value');
        
        % new viewing range
        nl = [com-vrhalf com+vrhalf];
        % jump by one view range
        set(axis1, 'XLim', nl);
    end

    function plotoverview(hObject, ~)
        % get settings
        handles = guidata(Parent);
        
        % if the user jumped away from an overview, we don't want to jump
        % back to the old coordinates
        
        % crude hack: if the viewed range is much (2x) smaller than the
        % full mass range we were probably not in overview mode. if at the
        % same time overview is still true, the user probably jumped out of
        % overview mode to a molecule and we should now go to overview
        cl = get(axis1, 'XLim');
        viewedrange = (cl(2) - cl(1))*2;
        
        maxmass = max(handles.massaxiscrop);
        
        if (viewedrange <= maxmass && handles.status.overview == 1)
            handles.status.overview = 0;
        end
        
        % are we already in overview?
        if handles.status.overview == 0
            % save the old settings so we can toggle back
            oxl = get(axis1, 'XLim');
            oyl = get(axis1, 'YLim');
            handles.status.lastlims = [oxl oyl];
            set(axis1, 'YLimMode', 'auto');
            set(axis1, 'XLimMode', 'auto');
            handles.status.overview = 1;
        elseif handles.status.overview == 1
            % jump back to last settings
            set(axis1, 'XLim', [handles.status.lastlims(1) handles.status.lastlims(2)]);
            set(axis1, 'YLim', [handles.status.lastlims(3) handles.status.lastlims(4)]);
            handles.status.overview = 0;
        end
        
        % save back
        guidata(Parent,handles);
    end

uiwait(Parent)

% is needed to update and save values before window is closed
show(Parent,0);

handles=guidata(Parent);

bgcorrectionout=handles.bgcorrectiondata;
startind=handles.startind;
endind=handles.endind;

close(Parent);
drawnow;

  
end
