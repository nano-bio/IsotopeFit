function calout = calibrate(peakdata,molecules,calin,settings)

% ############################## LAYOUT

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Mass-offset and resolution calibration',...
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


% Main Layout

SelectionPanel=uipanel(Parent,...
    'Tag','SelectionPanel',...
    'Title','Molecule selection',...
    'Units','normalized',...
    'Position',gridpos(16,1,12,16,1,1,0.01,1e-3));

PreviewPanel=uipanel(Parent,...
    'Tag','SelectionPanel',...
    'Title','Preview',...
    'Units','normalized',...
    'Position',gridpos(16,1,7,11,1,1,0.01,1e-3));

CalibrationPanel=uipanel(Parent,...
    'Tag','SelectionPanel',...
    'Title','Massoffset and resolution calibration',...
    'Units','normalized',...
    'Position',gridpos(16,1,2,6,1,1,0.01,1e-3));

uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback',@donecalib,...
          'Units','normalized',...
          'Position',gridpos(16,7,1,1,4,4,0.01,0.01)); 
     
% Selection Panel
 

uicontrol(SelectionPanel,'Style','Text',...
    'String','All Molecules',...
    'Units','normalized',...
    'Position',gridpos(12,8,12,12,1,3,0.01,0.01));

uicontrol(SelectionPanel,'Style','Text',...
    'String','Molecules for calibration',...
    'Units','normalized',...
    'Position',gridpos(12,8,12,12,6,8,0.01,0.01));

uicontrol(SelectionPanel,'Style','Text',...
    'String','Groups',...
    'Units','normalized',...
    'Position',gridpos(12,8,12,12,5,5,0.01,0.01));

ListAllMolecules=uicontrol(SelectionPanel,'Style','ListBox',...
    'Tag','ListAllMolecules',...
    'Units','normalized',...
    'Callback',@moleculepreview,...
    'Position',gridpos(12,8,1,11,1,3,0.01,0.1));

ListRelevantMolecules=uicontrol(SelectionPanel,'Style','ListBox',...
    'Tag','ListRelevantMolecules',...
    'Units','normalized',...
    'Callback',@moleculepreview,...
    'Position',gridpos(12,8,1,11,6,8,0.01,0.1));

ListRanges=uicontrol(SelectionPanel,'Style','ListBox',...
    'Tag','ListRanges',...
    'Units','normalized',...
    'Callback',@moleculepreview,...
    'Position',gridpos(12,8,1,11,5,5,0.01,0.1));

uicontrol(SelectionPanel,'style','pushbutton',...
          'string','->',...
          'Callback',@addtolist,...
          'Units','normalized',...
          'Position',gridpos(6,8,4,4,4,4,0.02,0.02)); 
      
uicontrol(SelectionPanel,'style','pushbutton',...
          'string','<-',...
          'Callback',@removefromlist,...
          'Units','normalized',...
          'Position',gridpos(6,8,3,3,4,4,0.02,0.02)); 

%Preview Panel

previewaxes = axes('Parent',PreviewPanel,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(10,8,2,10,1,6,0.05,0.15)); 

uicontrol(PreviewPanel,'Style','Text',...
    'String','Zoomfaktor',...
    'Units','normalized',...
    'Position',gridpos(10,10,1,1,1,1,0.01,0.01));        
         
e_zoomfaktor = uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_zoomfaktor',...
    'Units','normalized',...,...
    'String','30',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(10,10,1,1,2,2,0.01,0.01));
         
uicontrol(PreviewPanel,'Style','Text',...
    'String','Masscenter',...
    'Units','normalized',...
    'Position',gridpos(10,8,10,10,7,8,0.01,0.01));

e_com=uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_com',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Enable','off',...
    'Position',gridpos(10,8,9,9,7,8,0.01,0.01));

uicontrol(PreviewPanel,'Style','Text',...
    'String','Mass offset',...
    'Units','normalized',...
    'Position',gridpos(10,8,8,8,7,8,0.01,0.01));

e_massoffset=uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_massoffset',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Callback',@parametereditclick,...
    'Enable','off',...
    'Position',gridpos(10,8,7,7,7,7.4,0.01,0.01));

up1=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','massoffsetup',...
    'string','+',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,7,7,25,25,0.005,0.01));

down1=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','massoffsetdown',...    
    'string','-',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,7,7,26,26,0.005,0.01));

uicontrol(PreviewPanel,'Style','Text',...
    'String','Resolution',...
    'Units','normalized',...
    'Position',gridpos(10,8,6,6,7,8,0.01,0.01));

e_resolution=uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_resolution',...
    'Units','normalized',...
    'String','N/A',...
    'Callback',@parametereditclick,...
    'Background','white',...
    'Enable','off',...
    'Position',gridpos(10,8,5,5,7,7.4,0.01,0.01));

up2=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','resolutionup',...
    'string','+',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,5,5,25,25,0.005,0.01));

down2=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','resolutiondown',...    
    'string','-',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,5,5,26,26,0.005,0.01));

uicontrol(PreviewPanel,'Style','Text',...
    'String','Area',...
    'Units','normalized',...
    'Position',gridpos(10,8,4,4,7,8,0.01,0.01));

e_area=uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_area',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Callback',@parametereditclick,...
    'Enable','off',...
    'Position',gridpos(10,8,3,3,7,7.4,0.01,0.01));

up3=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','areaup',...
    'string','+',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,3,3,25,25,0.005,0.01));

down3=uicontrol(PreviewPanel,'style','pushbutton',...
    'Tag','areadown',...    
    'string','-',...
    'Callback',@parameterchange,...
    'Enable','off',...
    'Units','normalized',...
    'Position',gridpos(10,26,3,3,26,26,0.005,0.01));  

          
uicontrol(PreviewPanel,'style','pushbutton',...
          'string','Guess',...
          'Callback',@guessareaclick,...
          'Units','normalized',...
          'Position',gridpos(10,12,1,2,10,10,0.01,0.04)); 

uicontrol(PreviewPanel,'style','pushbutton',...
          'string','Fit this',...
          'Callback',@fitbuttonclick,...
          'Units','normalized',...
          'Position',gridpos(10,12,1,2,11,11,0.01,0.04)); 
      
uicontrol(PreviewPanel,'style','pushbutton',...
          'string','Fit all',...
          'Callback',@fitbuttonclick,...
          'Units','normalized',...
          'Position',gridpos(10,12,1,2,12,12,0.01,0.04)); 




%Calibration Panel

massoffsetaxes = axes('Parent',CalibrationPanel,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(10,2,2,10,1,1,0.05,0.15)); 
title(massoffsetaxes,'Mass offset');
         
         
resolutionaxes = axes('Parent',CalibrationPanel,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(10,2,2,10,2,2,0.05,0.15)); 
title(resolutionaxes,'Resolution');

uicontrol(CalibrationPanel,'Style','Text',...
    'HorizontalAlignment','right',...
    'String','Methode:',...
    'Units','normalized',...
    'Position',gridpos(10,7,1,1,1,1,0.01,0.01));

massmethode=uicontrol(CalibrationPanel,'style','popupmenu',...
          'string',{'Flat', 'Polynomial', 'Spline', 'PChip'},...
          'Callback',@massmethodechange,...
          'Units','normalized',...
          'Position',gridpos(10,7,1,1,2,2,0.02,0.01));

e_massoffsetorder=uicontrol(CalibrationPanel,'Style','edit',...
    'Tag','e_massoffsetorder',...
    'Units','normalized',...,...
    'String','0',...
    'Background','white',...    
    'Enable','on',...
    'Position',gridpos(10,7,1,1,3,3,0.05,0.01));

uicontrol(CalibrationPanel,'Style','Text',...
    'HorizontalAlignment','right',...
    'String','Resolution Order:',...
    'Units','normalized',...
    'Position',gridpos(10,7,1,1,5,5,0.01,0.01));

resolutionmethode=uicontrol(CalibrationPanel,'style','popupmenu',...
          'string',{'Flat','Polynomial', 'Spline', 'PChip'},...
          'Callback',@resolutionmethodechange,...
          'Units','normalized',...
          'Position',gridpos(10,7,1,1,6,6,0.02,0.01));
      
e_resolutionorder=uicontrol(CalibrationPanel,'Style','edit',...
    'Tag','e_massoffsetorder',...
    'Units','normalized',...,...
    'String','0',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(10,7,1,1,7,7,0.05,0.01));

uicontrol(CalibrationPanel,'style','pushbutton',...
          'string','Update',...
          'Callback',@updatepolynomials,...
          'Units','normalized',...
          'Position',gridpos(10,7,1,1,4,4,0.05,0.01)); 

% ############################## END OF LAYOUT
% 

handles=guidata(Parent);

handles.peakdata = peakdata;
handles.molecules = molecules;
handles.ranges = {};

handles.settings=settings;

handles.calibrationlist=[]; 

% Init. calibration structure
handles.calibration=calin;

if ~isempty(handles.calibration.namelist)
    for i=1:length(handles.molecules)
        if ismember(handles.molecules{i}.name,handles.calibration.namelist)
            handles.calibrationlist=[handles.calibrationlist i];
        end
    end
    
    handles.ranges=findranges(handles.molecules(handles.calibrationlist),handles.calibration,handles.settings.searchrange);
    handles.ranges=addrangeparameters(handles.ranges,handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.resolutionlist);
    guidata(Parent,handles);
    ranges2listbox(1,1);
end


set(massmethode,'Value',getnameidx(get(massmethode,'String'),handles.calibration.massoffsetmethode));
set(e_massoffsetorder,'String',num2str(handles.calibration.massoffsetparam));
set(resolutionmethode,'Value',getnameidx(get(resolutionmethode,'String'),handles.calibration.resolutionmethode));
set(e_resolutionorder,'String',num2str(handles.calibration.resolutionparam));

%Abspeichern der Struktur 
guidata(Parent,handles); 

%load moleculelist
molecules2listbox(ListAllMolecules,handles.molecules);

%update calibrationplots
updatepolynomials(Parent,0);

calout=handles.calibration;
calout.namelist=ranges2namelist(handles.ranges);

uiwait(Parent)


    function donecalib(hObject,~)
        
    % check if fitted resolution is negative for any mass (can be the case
    % for high masses when using polynomial fit)
        res = resolutionbycalibration(handles.calibration, peakdata(:,1));
        offset = massoffsetbycalibration(handles.calibration, peakdata(:,1));
        offsetdiff = diff(peakdata(:,1))-diff(offset);
        if sum(res<0) > 0
            choise = questdlg(sprintf('Resolution gets negative for high masses. This could lead to problems in the fitting procedure. \n Please, change method or add calibration molecules. \n Do you want to continue without changing your settings?'),...
                'Negative Resolution',...
                'Yes', 'No', 'No');
            switch choise
                case 'Yes'
                    calout=handles.calibration;
                    calout.namelist=ranges2namelist(handles.ranges);

                    drawnow;
                    uiresume(gcbf);
                    close(Parent);
        
                %case 'No'
            end
        % check if gradient of mass offset is not steeper than gradient of
        % original mass axis in order to keep monotonicity of calibrated
        % mass axis  
        elseif sum(offsetdiff<0)>0
             choise = questdlg(sprintf('Gradient of mass offset is too steep. This could lead to problems in the fitting procedure. \n Please, change method or add calibration molecules. \n Do you want to continue without changing your settings?'),...
                'Mass Offset Gradient Too Steep',...
                'Yes', 'No', 'No');
            switch choise
                case 'Yes'
                    calout=handles.calibration;
                    calout.namelist=ranges2namelist(handles.ranges);

                    drawnow;
                    uiresume(gcbf);
                    close(Parent);
        
                %case 'No'
            end
        else
            calout=handles.calibration;
            calout.namelist=ranges2namelist(handles.ranges);

            drawnow;
            uiresume(gcbf);
            close(Parent);
        end
    end

%################### INTERNAL FUNCTIONS
    function guessareaclick(hObject, ~)
        [rootindex, rangeindex, moleculeindex]=getcurrentindex();
        
        handles=guidata(hObject);
        
        for i=1:length(handles.ranges{rangeindex}.molecules)
            [percent,ix]=max(handles.ranges{rangeindex}.molecules{i}.peakdata(:,2));
            mass=handles.ranges{rangeindex}.molecules{i}.peakdata(ix,1);
                       
            sigma=mass/handles.ranges{rangeindex}.resolution; %guess sigma by center of mass of first molecule
            
            minmass=mass+handles.ranges{rangeindex}.massoffset-sigma;
            maxmass=mass+handles.ranges{rangeindex}.massoffset+sigma;
            
            minind=mass2ind(handles.peakdata(:,1)',minmass);
            maxind=mass2ind(handles.peakdata(:,1)',maxmass);
            
            handles.ranges{rangeindex}.molecules{i}.area=max(0,sum(peakdata(minind:maxind,2).*diff(peakdata(minind:maxind+1,1)))/(percent*0.862)); %68.2% in [-sigma +sigma]
            handles.molecules{handles.ranges{rangeindex}.molecules{i}.rootindex}.area=handles.ranges{rangeindex}.molecules{i}.area;
        end
        
        guidata(hObject,handles);
        updatemolecules(handles.ranges(rangeindex));
        
        writetopreviewedit(handles.ranges{rangeindex}.com,handles.ranges{rangeindex}.massoffset,...
            handles.ranges{rangeindex}.resolution,handles.ranges{rangeindex}.molecules{moleculeindex}.area);
        
        [handles.calibration.comlist, handles.calibration.massoffsetlist, handles.calibration.resolutionlist]=ranges2list(handles.ranges);
        
        guidata(hObject,handles);
        
        plotpreview(rootindex);
        plotdatapoints;
    end

    function massmethodechange(hObject, ~)
        handles=guidata(Parent);
        methode=get(hObject,'String');
        handles.calibration.massoffsetmethode=methode{get(hObject,'Value')};
        guidata(Parent,handles);
    end

    function resolutionmethodechange(hObject, ~)
        handles=guidata(Parent);
        methode=get(hObject,'String');
        handles.calibration.resolutionmethode=methode{get(hObject,'Value')};
        guidata(Parent,handles);        
    end

    function updatemolecules(ranges)
        handles=guidata(Parent);
        for i=1:length(ranges)
            for j=1:length(ranges{i}.molecules)
            handles.molecules{ranges{i}.molecules{j}.rootindex}.area=ranges{i}.molecules{j}.area;
            handles.molecules{ranges{i}.molecules{j}.rootindex}.areaerror=ranges{i}.molecules{j}.areaerror;
            end
        end
        guidata(Parent,handles);
        
    end
    
    function fitbuttonclick(hObject, ~)
        handles=guidata(hObject);
        
        [rootindex, rangeindex, moleculeindex]=getcurrentindex();
        switch get(hObject,'String')
            case 'Fit this'
                handles.ranges(rangeindex)=fitranges(handles.peakdata,handles.ranges(rangeindex),inf,0.5,0.5,'simplex');
                guidata(hObject,handles);
                updatemolecules(handles.ranges(rangeindex));
            case 'Fit all'
                handles.ranges=fitranges(handles.peakdata,handles.ranges,inf,0.5,0.5,'simplex');
                guidata(hObject,handles);
                updatemolecules(handles.ranges);
        end
        
        writetopreviewedit(handles.ranges{rangeindex}.com,handles.ranges{rangeindex}.massoffset,...
            handles.ranges{rangeindex}.resolution,handles.ranges{rangeindex}.molecules{moleculeindex}.area);
        
        [handles.calibration.comlist, handles.calibration.massoffsetlist, handles.calibration.resolutionlist]=ranges2list(handles.ranges);
        
        guidata(hObject,handles);
        
        plotpreview(rootindex);
        plotdatapoints;
    end

    function writetopreviewedit(com,massoffset,resolution,area)
        set(e_com,'String',num2str(com));
        set(e_area,'String',num2str(area));
        set(e_massoffset,'String',num2str(massoffset));
        set(e_resolution,'String',num2str(resolution));
    end

    function updatepolynomials(hObject, ~)
      
        handles=guidata(Parent);
        %[comlist, massoffsetlist, resolutionlist]=ranges2list(handles.ranges);
        
        massaxis=handles.peakdata(:,1)';
        
        %massoffset plot
              
        
        switch(handles.calibration.massoffsetmethode)
            case 'Flat'
                handles.calibration.massoffsetparam=mean(handles.calibration.massoffsetlist);
            case 'Polynomial'
                nmassoffset=str2double(get(e_massoffsetorder,'String'));
                
                if nmassoffset>=length(handles.calibration.comlist) %polynomial with this order not possible
                    msgbox('polynomial order too high!');
                    nmassoffset=length(handles.calibration.comlist)-1;
                    set(e_massoffsetorder,'String',num2str(nmassoffset));
                end
                handles.calibration.massoffsetparam=nmassoffset;                
               
        end
        
        massoffsety=getcalibrationdata(handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.massoffsetparam,handles.calibration.massoffsetmethode,massaxis);
        
        %resolution plot
        switch(handles.calibration.resolutionmethode)
            case 'Flat'
                handles.calibration.resolutionparam=mean(handles.calibration.resolutionlist);
            case 'Polynomial'
                nresolution=str2double(get(e_resolutionorder,'String'));
                
                if nresolution>=length(handles.calibration.comlist) %polynomial with this order not possible
                    msgbox('polynomial order too high!');
                    nresolution=length(handles.calibration.comlist)-1;
                    set(e_resolutionorder,'String',num2str(nmassoffset));
                end
                handles.calibration.resolutionparam=nresolution;  
        end
        
        resolutiony=getcalibrationdata(handles.calibration.comlist,handles.calibration.resolutionlist,handles.calibration.resolutionparam,handles.calibration.resolutionmethode,massaxis);
        
        
        guidata(Parent,handles);
        
        plotdatapoints;
        
        hold(massoffsetaxes,'on');
        plot(massoffsetaxes,massaxis,massoffsety,'k--');
        hold(massoffsetaxes,'off');
        
        hold(resolutionaxes,'on');
        plot(resolutionaxes,massaxis,resolutiony,'k--');
        hold(resolutionaxes,'off');
        
    end

    function [rootindex, rangeindex, moleculeindex]=getcurrentindex()
        %reads out indices of current molecule
        handles=guidata(Parent);
        rangeindex=get(ListRanges,'Value');
        moleculeindex=get(ListRelevantMolecules,'Value');
        rootindex=handles.ranges{rangeindex}.molecules{moleculeindex}.rootindex;
    end

    function updatecurrentmolecule()
      
        [rootindex, rangeindex, moleculeindex]=getcurrentindex();

        handles=guidata(Parent);

        handles.ranges{rangeindex}.massoffset=str2double(get(e_massoffset,'String'));
        handles.ranges{rangeindex}.resolution=str2double(get(e_resolution,'String'));
        handles.molecules{rootindex}.area=str2double(get(e_area,'String'));
        handles.ranges{rangeindex}.molecules{moleculeindex}.area=str2double(get(e_area,'String'));
        
        handles.ranges(rangeindex)=calccomofranges(handles.ranges(rangeindex));
        
        set(e_com,'String',num2str(handles.ranges{rangeindex}.com));
     
        [handles.calibration.comlist, handles.calibration.massoffsetlist, handles.calibration.resolutionlist]=ranges2list(handles.ranges);
        guidata(Parent,handles);
        plotpreview(rootindex);
        %fitpolynomials();
        plotdatapoints();
    end
    
    function [comlist, massoffsetlist, resolutionlist]=ranges2list(ranges)
        % how many ranges?
        nor = length(ranges);
        
        comlist = zeros(nor, 1);
        massoffsetlist = zeros(nor, 1);
        resolutionlist = zeros(nor, 1);
        
        for i=1:length(ranges)
            comlist(i)=ranges{i}.com;
            massoffsetlist(i)=ranges{i}.massoffset;
            resolutionlist(i)=ranges{i}.resolution;
        end
    end

    function out=ranges2namelist(ranges)
        out={};
        k=1;
        for i=1:length(ranges)
            for j=1:length(ranges{i}.molecules)
                out{k}=ranges{i}.molecules{j}.name;
                k=k+1;
            end
        end
    end

    function plotdatapoints()
        handles=guidata(Parent);
        
        if ~isempty(handles.calibrationlist)
            % plot mass offset
            plot(massoffsetaxes,handles.calibration.comlist,handles.calibration.massoffsetlist,'ko');
            xlim(massoffsetaxes,[min(handles.calibration.comlist)-1,max(handles.calibration.comlist)+1]);       
            
            % plot resolution
            plot(resolutionaxes,handles.calibration.comlist,handles.calibration.resolutionlist,'ko');
            xlim(resolutionaxes,[min(handles.calibration.comlist)-1,max(handles.calibration.comlist)+2]);
            

        else
            cla(massoffsetaxes);
            cla(resolutionaxes);
        end
        
        
        guidata(Parent,handles);
    end

    function markpoints()
        handles = guidata(Parent);
        
        % we only need this if there are calibration values available
        if ~isempty(handles.calibrationlist)
            
            % the only interesting parameter is the range (since we only
            % have one datapoint for each range
            callistindex = get(ListRanges,'Value');
            
            % get the according values for mass, res and offset
            com = handles.calibration.comlist(callistindex);
            res = handles.calibration.resolutionlist(callistindex);
            mos = handles.calibration.massoffsetlist(callistindex);
            
            % first for the massoffset. we try to delete the old marking,
            % if available
            hold(massoffsetaxes, 'on');
            try
                delete(handles.mowriteindication)
            end
            handles.mowriteindication = stem(massoffsetaxes, com, mos,'g');
            hold(massoffsetaxes, 'off');
            
            % now for the resolution
            hold(resolutionaxes, 'on');
            try
                delete(handles.reswriteindication);
            end
            handles.reswriteindication = stem(resolutionaxes, com, res,'g');
            hold(resolutionaxes, 'off');
        end
        
        guidata(Parent,handles);
    end

    function plotpreview(index)
        handles=guidata(Parent);
        
        com=handles.molecules{index}.com;
        
        [inrange, rangeindex, moleculeindex] = memberofrange(handles.ranges,index);
        
        if ~inrange %molecule not in calibrationlist
            involvedmolecules=index;
      
            [currentmassoffset,currentresolution]=parameterinterpolation(handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.resolutionlist,com);
            
            %limits for calculation
%             com=calccomofmolecules(handles.molecules(index));
%             xmin=handles.molecules{index}.minmass;
%             xmax=handles.molecules{index}.maxmass;
        else
            involvedmolecules=findinvolvedmolecules(handles.molecules,handles.calibrationlist,index,handles.settings.searchrange,handles.calibration);%search in calibrationlist
            currentmassoffset=handles.ranges{rangeindex}.massoffset;
            currentresolution=handles.ranges{rangeindex}.resolution;
            
            %limits for calculation
%             com=calccomofmolecules(handles.molecules(involvedmolecules));
%             xmin=handles.molecules{involvedmolecules(1)}.minmass;
%             xmax=handles.molecules{involvedmolecules(end)}.maxmass;
            
        end
        
        zoom=str2double(get(e_zoomfaktor,'String'));
        
        %calculate massreange with respect to resolution
        ind=findmassrange(handles.peakdata(:,1)',handles.molecules(involvedmolecules),currentresolution,currentmassoffset,zoom);
                
        %calculate single molecule and sum of molecules in this massrange
        calcmassaxis=handles.peakdata(ind,1)';
        %calcsignal=pattern(handles.molecules{index},area,currentresolution,currentmassoffset,calcmassaxis);
        calcsignal=multispec(handles.molecules(index),...
                currentresolution,...
                currentmassoffset,...
                calcmassaxis); 
            
                %plotting data
        plot(previewaxes,handles.peakdata(:,1)',handles.peakdata(:,2)','Color',[0.5 0.5 0.5]);
        hold(previewaxes,'on');
        
   
        
        %calculate and plot sum spectrum of involved molecules if current
        %molecule is in calibrationlist
        if inrange
            sumspectrum=multispec(handles.ranges{rangeindex}.molecules,...
                currentresolution,...
                currentmassoffset,...
                calcmassaxis);
        
            plot(previewaxes,calcmassaxis,sumspectrum,'k--','Linewidth',2); 
        end
        
        plot(previewaxes,calcmassaxis,calcsignal,'Color','red');
        
        hold(previewaxes,'off');
        
        %Zoom data
        %[~,i]=max(handles.molecules{index}.peakdata(:,2));
        
        xlim(previewaxes,[calcmassaxis(1),calcmassaxis(end)]);  
        %ylim(previewaxes,[0,max(max(handles.molecules{index}.peakdata(:,2)),max(handles.peakdata(handles.molecules{index}.minind:handles.molecules{index}.maxind,2)))]);
        
        guidata(Parent,handles);
    end

    function moleculepreview(hObject, ~)
        handles=guidata(hObject);
        sendertag=get(hObject,'Tag');
        
        clickedindex=get(hObject,'Value');
        inrange=true;
        switch sendertag
            case 'ListRelevantMolecules'
                rangeindex=get(ListRanges,'Value');
                moleculeindex=clickedindex;
                index=handles.ranges{rangeindex}.molecules{clickedindex}.rootindex;
                com=handles.ranges{rangeindex}.com;
            case 'ListRanges'
                rangeindex=clickedindex;
                moleculeindex=1;
                ranges2listbox(rangeindex,moleculeindex);
                set(ListRelevantMolecules,'Value',1);
                index=handles.ranges{clickedindex}.molecules{1}.rootindex;
                com=handles.ranges{clickedindex}.com; 
            otherwise
                [inrange, rangeindex, moleculeindex] = memberofrange(handles.ranges,clickedindex);
                index=clickedindex;
                com=handles.molecules{index}.com;
        end
        
        if ~inrange
            previewpaneledit('off');
            %guess resolution and massoffset            
            
            [currentmassoffset,currentresolution]=parameterinterpolation(handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.resolutionlist,com);
        else
            previewpaneledit('on');
            %[~, rangeindex, ~] = memberofrange(handles.ranges,index);
            currentmassoffset=handles.ranges{rangeindex}.massoffset;
            currentresolution=handles.ranges{rangeindex}.resolution;
            set(ListRanges,'Value',rangeindex);
            molecules2listbox(ListRelevantMolecules,handles.ranges{rangeindex}.molecules);
            set(ListRelevantMolecules,'Value',moleculeindex);
        end
               
        set(ListAllMolecules,'Value',index);
        
        area=handles.molecules{index}.area;
        guidata(hObject,handles);
        
        writetopreviewedit(com,currentmassoffset,currentresolution,area)
        plotpreview(index);
        
        % in the very end we update the resolution and mass offset axes.
        markpoints();
        
    end

    function previewpaneledit(value)
        %set(e_com,'Enable',value);
        set(e_area,'Enable',value);
        set(e_massoffset,'Enable',value);
        set(e_resolution,'Enable',value);
        set(up1,'Enable',value);
        set(up2,'Enable',value);
        set(up3,'Enable',value);
        set(down1,'Enable',value);
        set(down2,'Enable',value);
        set(down3,'Enable',value);
    end

    function addtolist(hObject, ~)
        %adds marked element in moleculelistbox to calibration listbox
        
        handles=guidata(hObject);
        
        index=get(ListAllMolecules,'Value');
%       
        if sum(handles.calibrationlist==index)==1 %Already added
            msgbox('This Molecule is already in list!')
        else
            [handles.calibrationlist]=sort([handles.calibrationlist index]);

            handles.ranges=findranges(handles.molecules(handles.calibrationlist),handles.calibration,handles.settings.searchrange);
            handles.ranges=addrangeparameters(handles.ranges,handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.resolutionlist);
            
            [handles.calibration.comlist, handles.calibration.massoffsetlist, handles.calibration.resolutionlist]=ranges2list(handles.ranges);
                    
            guidata(hObject,handles);
            
            [~, rangeindex, moleculeindex]=memberofrange(handles.ranges,index);
            
            ranges2listbox(rangeindex,moleculeindex);
            
            plotdatapoints();
            %set selection to recently added entry
            handles=guidata(hObject);
            
            previewpaneledit('on');
        end        
    end

    function removefromlist(hObject, ~)
        %removes marked element from calibration listbox
        
        handles=guidata(hObject);
        
        index=handles.ranges{get(ListRanges,'Value')}.molecules{get(ListRelevantMolecules,'Value')}.rootindex;
        
        handles.calibrationlist=handles.calibrationlist(handles.calibrationlist~=index);
        
        if ~isempty(handles.calibrationlist)
            handles.ranges=findranges(handles.molecules(handles.calibrationlist),handles.calibration,handles.settings.searchrange);
            handles.ranges=addrangeparameters(handles.ranges,handles.calibration.comlist,handles.calibration.massoffsetlist,handles.calibration.resolutionlist);
            [handles.calibration.comlist, handles.calibration.massoffsetlist, handles.calibration.resolutionlist]=ranges2list(handles.ranges); 
        else
            handles.ranges={};
        end
        guidata(hObject,handles);
        
        % try to go to same range and previous molecule. or go to the first in 
        % that special case...
        prevrangeindex = min(get(ListRanges,'Value'),length(handles.ranges));
        prevmoleculeindex = max(get(ListRelevantMolecules,'Value') - 1,1);
 
        ranges2listbox(prevrangeindex,prevmoleculeindex);

        plotdatapoints();
        previewpaneledit('off');
    end

    function ranges2listbox(rangeindex,moleculeindex)
        handles=guidata(Parent);
        
        if ~isempty(handles.ranges)
            
            temp='';
            for i=1:length(handles.ranges)
                temp{i}=num2str(i);
            end
            
            set(ListRanges,'String',temp);
            set(ListRanges,'Value',rangeindex);
            
            molecules2listbox(ListRelevantMolecules,handles.ranges{rangeindex}.molecules);
            
            set(ListRelevantMolecules,'Value',moleculeindex);
        else
            set(ListRanges,'String','');
            set(ListRanges,'Value',1);
            set(ListRelevantMolecules,'String','');
            set(ListRelevantMolecules,'Value',1);
        end
        
        guidata(Parent,handles);
    end
  
    function parametereditclick(hObject, ~)
        updatecurrentmolecule();
    end

    function parameterchange(hObject, ~)
        handles=guidata(hObject);
        tag=get(hObject,'Tag');
        
        % we want to preserve the zoom status on a parameter change
        xlims = get(previewaxes, 'XLim');
        ylims = get(previewaxes, 'YLim');
        
        switch tag
            case 'massoffsetup'
                value=str2double(get(e_massoffset,'String'));
                value=value+0.01;
                set(e_massoffset,'String',num2str(value));
            case 'massoffsetdown'
                value=str2double(get(e_massoffset,'String'));
                value=value-0.01;
                set(e_massoffset,'String',num2str(value));
            case 'resolutionup'
                value=str2double(get(e_resolution,'String'));
                value=value+0.05*value;
                set(e_resolution,'String',num2str(value));
            case 'resolutiondown'
                value=str2double(get(e_resolution,'String'));
                value=value-0.05*value;
                set(e_resolution,'String',num2str(value));
            case 'areaup'
                value=str2double(get(e_area,'String'));
                value=value+0.05*value;
                set(e_area,'String',num2str(value));   
            case 'areadown'
                value=str2double(get(e_area,'String'));
                value=value-0.05*value;
                set(e_area,'String',num2str(value));                
        end
        guidata(hObject,handles);
        updatecurrentmolecule();
        
        % we write that back now after the plotting, because we don't want
        % to change the actual plotting function (hence keeping the
        % behaviour of auto-resizing when selecting a molecule)
        set(previewaxes, 'XLim', xlims);
        set(previewaxes, 'YLim', ylims);
%         handles=guidata(hObject);
%         
%         guidata(hObject,handles);
        
    end  
end
