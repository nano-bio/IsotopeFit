function [bgcorrectionout, startind, endind] = bg_correction(peakdata,bgcorrectiondata)

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

layoutlines=30;
layoutrows=30;

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
    'Position',gridpos(layoutlines,layoutrows,29,30,3,4,0.01,0.01));

e_startmass=uicontrol(Parent,'Style','edit',...
    'Tag','edit_startmass',...
    'Units','normalized',...,...
    'String','0',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,29,30,5,6,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'Tag','TextEndMass',...
    'String','End Mass',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,29,30,7,8,0.01,0.01));

e_endmass=uicontrol(Parent,'Style','edit',...
    'Tag','edit_endmass',...
    'Units','normalized',...,...
    'String','End',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,29,30,9,10,0.01,0.01));
% 
% axis1 = axes('Parent',Parent,...
%              'ActivePositionProperty','OuterPosition',...
%              'Units','normalized',...
%              'Position',gridpos(66,60,17,61,4,60,0.04,0.04));
         
% for backwards compatibility with the existing code, we map updateslider
% to the function inside the dataviewer object
dvhandle = dataviewer(Parent, gridpos(layoutlines,layoutrows,4,28,1,layoutrows,0.025,0.01), 50, 40, false);
axis1 = dvhandle.axes;
updateslider = dvhandle.updateslider;

e_ndiv=uicontrol(Parent,'Style','edit',...
    'Tag','edit_ndiv',...
    'String','10',...
    'Units','normalized',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,1,2,3,4,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'Tag','Text1',...
    'String','Number of divisions',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,1,2,1,2,0.01,0.01));

e_percent=uicontrol(Parent,'Style','edit',...
    'Tag','edit_npoints',...
    'String','10',...
    'Units','normalized',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,1,2,7,8,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'Tag','Text2',...
    'String','Evaluation points (%)',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,1,2,5,6,0.01,0.01));
         
uicontrol(Parent,'style','pushbutton',...
          'string','Show',...
          'Callback',@show,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,9,20,0.01,0.01)); 

% when OK is pushed uiwait ends 
uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback','uiresume(gcbf)',...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,21,layoutrows,0.01,0.01)); 
      
% Plot overview
      
uicontrol(Parent,'style','pushbutton',...
          'string','OV',...
          'Callback',@plotoverview,...
          'Units','normalized',...
          'TooltipString','Plot whole mass spec (overview)',...
          'Position',gridpos(layoutlines,layoutrows,29,30,1,2,0.01,0.01));

% ############################## END OF LAYOUT

handles=guidata(Parent);

handles.massaxis = peakdata(:,1)';
handles.signal = peakdata(:,2)'; 
handles.bgdata = zeros(1,size(peakdata,1));

handles.bgcorrectiondata=bgcorrectiondata;

handles.startup = 1;

set(e_startmass,'String',num2str(bgcorrectiondata.startmass));
set(e_endmass,'String',num2str(bgcorrectiondata.endmass));
set(e_ndiv,'String',num2str(bgcorrectiondata.ndiv));
set(e_percent,'String',num2str(bgcorrectiondata.percent));


% Abspeichern der Struktur 
guidata(Parent,handles); 

show(Parent,0);

function show(hObject, ~)
    handles=guidata(hObject);
    handles.bgcorrectiondata.ndiv=str2double(get(e_ndiv,'String'));
    handles.bgcorrectiondata.percent=str2double(get(e_percent,'String'));
    %handles.bgcorrectiondata.polydegree=str2num(get(e_polydegree,'String'));

    % retrieve current view settings from axes:
    if (handles.startup == 0) % only if we're not starting up any more...
        xlim = get(axis1, 'XLim');
        ylim = get(axis1, 'YLim');
    end

    % read out the two fields for start and end mass. in case they are
    % set to "start" and "end" respectively, set them to +- infinity

    % start mass
    sm_str=get(e_startmass,'String');
    if strcmp(sm_str,'start')
        handles.bgcorrectiondata.startmass=-inf;
    else
        handles.bgcorrectiondata.startmass=str2double(sm_str);
    end

    % end mass
    em_str=get(e_endmass,'String');
    if strcmp(em_str,'end')
        handles.bgcorrectiondata.endmass=+inf;
    else
        handles.bgcorrectiondata.endmass=str2double(em_str);
    end

    % call the function that actually calculates the background values
    % for each section. it returns two lists: bgm und bgy - bgy gives a
    % background level for each section, bgm the according mass (placed
    % in the center of the section)
    [handles.bgcorrectiondata.bgm,handles.bgcorrectiondata.bgy, handles.startind, handles.endind]=...
        find_bg(handles.massaxis,handles.signal,...
            handles.bgcorrectiondata.ndiv,...
            handles.bgcorrectiondata.percent,...
            handles.bgcorrectiondata.startmass,...
            handles.bgcorrectiondata.endmass);

    % crop the mass and signal axes to the values used for determining
    % the background levels
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

% initialize some status values needed for the view change functions
handles.status.logscale = 0;
handles.status.overview = 0;
handles.status.lastlims = [[0 0] [0 0]];

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
