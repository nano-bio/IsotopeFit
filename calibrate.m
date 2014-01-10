function [massoffset resolution] = calibrate(peakdata,molecules)

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Background correction',...
    'Units','normalized',...
    'Position',[0.4,0.1,0.4,0.8]); 

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
          'Callback','uiresume(gcbf)',...
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
             'Position',gridpos(5,8,1,5,1,6,0.05,0.15)); 

uicontrol(PreviewPanel,'Style','Text',...
    'String','Masscenter',...
    'Units','normalized',...
    'Position',gridpos(10,8,10,10,7,8,0.01,0.01));

e_com=uicontrol(PreviewPanel,'Style','edit',...
    'Tag','e_com',...
    'Units','normalized',...,...
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
    'Units','normalized',...,...
    'String','N/A',...
    'Background','white',...
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
          'string','update',...
          'Callback','',...
          'Units','normalized',...
          'Position',gridpos(10,8,1,2,7.5,7.5,0.02,0.04)); 

    


%Calibration Panel

massoffsetaxes = axes('Parent',CalibrationPanel,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(10,2,2,10,1,1,0.05,0.15)); 

resolutionaxes = axes('Parent',CalibrationPanel,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(10,2,2,10,2,2,0.05,0.15)); 

uicontrol(CalibrationPanel,'Style','Text',...
    'HorizontalAlignment','right',...
    'String','Massoffset Order:',...
    'Units','normalized',...
    'Position',gridpos(10,5,1,1,1,1,0.01,0.01));

e_massoffsetorder=uicontrol(CalibrationPanel,'Style','edit',...
    'Tag','e_massoffsetorder',...
    'Units','normalized',...,...
    'String','3',...
    'Background','white',...    
    'Callback',@orderchange,...
    'Enable','on',...
    'Position',gridpos(10,5,1,1,2,2,0.05,0.01));

uicontrol(CalibrationPanel,'Style','Text',...
    'HorizontalAlignment','right',...
    'String','Resolution Order:',...
    'Units','normalized',...
    'Position',gridpos(10,5,1,1,4,4,0.01,0.01));

e_resolutionorder=uicontrol(CalibrationPanel,'Style','edit',...
    'Tag','e_massoffsetorder',...
    'Units','normalized',...,...
    'String','3',...
    'Background','white',...
    'Callback',@orderchange,...
    'Enable','on',...
    'Position',gridpos(10,5,1,1,5,5,0.05,0.01));

uicontrol(CalibrationPanel,'style','pushbutton',...
          'string','update',...
          'Callback','',...
          'Units','normalized',...
          'Position',gridpos(10,5,1,1,3,3,0.05,0.01)); 

% ############################## END OF LAYOUT
% 

handles=guidata(Parent);

handles.peakdata = peakdata;
handles.molecules = molecules;
handles.ranges = {};

handles.resolutionpolynom=3000;
handles.massoffsetpolynom=0;

handles.calibrationlist=[]; %list of molecule indices for calibration
handles.massoffsetlist=[]; %list of massoffset-points (on center of mass of every molecule)
handles.resolutionlist=[]; %list of resolution-points (on com of every molecule)
handles.comlist=[];

%handles.currentmolecule=0; %molecule shown in preview Window

plot(previewaxes,peakdata(:,1),peakdata(:,2));

%Abspeichern der Struktur 
guidata(Parent,handles); 

%load moleculelist
for i=1:length(molecules)
   temp{i}=molecules{i}.name;
end

set(ListAllMolecules,'String',temp);

uiwait(Parent)
% %out = get(e,'String');
% 
% handles=guidata(Parent);
% massout=handles.massaxiscrop;
% signalout= handles.signalcrop-handles.bgdata;
% 
 close(Parent);
% drawnow;


%################### INTERNAL FUNCTIONS
    function writetopreviewedit(com,massoffset,resolution,area)
        set(e_com,'String',num2str(com));
        set(e_area,'String',num2str(area));
        set(e_massoffset,'String',num2str(massoffset));
        set(e_resolution,'String',num2str(resolution));
    end

    function orderchange(hObject,eventdata)
        fitpolynomials;
    end

    function fitpolynomials()
        handles=guidata(Parent);
        
        nmassoffset=str2double(get(e_massoffsetorder,'String'));
        
        if nmassoffset>=length(handles.calibrationlist) %polynomial with this order not possible
            nmassoffset=length(handles.calibrationlist)-1;
            set(e_massoffsetorder,'String',num2str(nmassoffset));
        end
        
        nresolution=str2double(get(e_resolutionorder,'String'));
        
        if nresolution>=length(handles.calibrationlist) %polynomial with this order not possible
            nresolution=length(handles.calibrationlist)-1;
            set(e_resolutionorder,'String',num2str(nmassoffset));
        end
        
        %fitting
        handles.resolutionpolynom=polyfit(handles.comlist,handles.resolutionlist,nresolution);
        handles.massoffsetpolynom=polyfit(handles.comlist,handles.massoffsetlist,nmassoffset);
        
        guidata(Parent,handles);
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
        handles.ranges{rangeindex}.massoffset=str2double(get(e_resolution,'String'));
        handles.molecules{rootindex}.area=str2double(get(e_area,'String'));
        handles.ranges{rangeindex}.molecules{moleculeindex}.area=str2double(get(e_area,'String'));
        
        guidata(Parent,handles);
        
        plotpreview(rootindex);
        %fitpolynomials();
        plotdatapoints();
    end
    
    function [comlist, massoffsetlist, resolutionlist]=ranges2list(ranges)
        comlist=[];
        massoffsetlist=[];
        resolutionlist=[];
        
        for i=1:length(ranges)
            comlist(i)=ranges{i}.com;
            massoffsetlist(i)=ranges{i}.com;
            resolutionlist(i)=ranges{i}.com;
        end
    end

    function plotdatapoints()
        handles=guidata(Parent);
        
        if ~isempty(handles.calibrationlist)
            massaxis=handles.peakdata(:,1)';
            
            [comlist, massoffsetlist, resolutionlist]=ranges2list(handles.ranges);
            
            plot(massoffsetaxes,comlist,massoffsetlist,'ko');
            hold(massoffsetaxes,'on');
            plot(massoffsetaxes,massaxis,polynomial(handles.massoffsetpolynom,massaxis),'k--');
            hold(massoffsetaxes,'off');
            
            xlim(massoffsetaxes,[min(massaxis),max(massaxis)]);
                        
            plot(resolutionaxes,comlist,resolutionlist,'ko');
            hold(resolutionaxes,'on');
            plot(resolutionaxes,massaxis,polynomial(handles.resolutionpolynom,massaxis),'k--');
            hold(resolutionaxes,'off');
            
            xlim(resolutionaxes,[min(massaxis),max(massaxis)]);
            
        else
            cla(massoffsetaxes);
            cla(resolutionaxes);
        end
        
        
        guidata(Parent,handles);
    end

    function plotpreview(index)
        handles=guidata(Parent);
        
        area=handles.molecules{index}.area;
        com=handles.molecules{index}.com;
        
        [inrange, rangeindex, moleculeindex] = memberofrange(handles.ranges,index);
        
        if ~inrange %molecule not in calibrationlist
            %limits for calculation
            xmin=handles.molecules{index}.minmass;
            xmax=handles.molecules{index}.maxmass;
            currentmassoffset=polynomial(handles.massoffsetpolynom,com);
            currentresolution=polynomial(handles.resolutionpolynom,com);
        else
            involvedmolecules=findinvolvedmolecules(handles.molecules,handles.calibrationlist,index);%search in calibrationlist
            %limits for calculation
            xmin=handles.molecules{involvedmolecules(1)}.minmass;
            xmax=handles.molecules{involvedmolecules(end)}.maxmass;
            
            currentmassoffset=handles.ranges{rangeindex}.massoffset;
            currentresolution=handles.ranges{rangeindex}.resolution;
        end
                
        %calculate single molecule and sum of molecules in this massrange
        calcmassaxis=handles.peakdata(mass2ind(handles.peakdata(:,1),xmin-1):mass2ind(handles.peakdata(:,1),xmax+1),1)';
        %calcsignal=pattern(handles.molecules{index},area,currentresolution,currentmassoffset,calcmassaxis);
        calcsignal=multispec(handles.molecules(index),...
                handles.resolutionpolynom,...
                handles.massoffsetpolynom,...
                calcmassaxis); 
            
                %plotting data
        plot(previewaxes,handles.peakdata(:,1)',handles.peakdata(:,2)','Color',[0.6 0.6 0.6]);
        hold(previewaxes,'on');
        plot(previewaxes,calcmassaxis,calcsignal,'Color',[0.6 0.6 0.9],'Linewidth',2); 
   
        %calculate and plot sum spectrum of involved molecules if current
        %molecule is in calibrationlist
        if sum(index==handles.calibrationlist)~=0
            sumspectrum=multispec(handles.molecules(involvedmolecules),...
                handles.resolutionpolynom,...
                handles.massoffsetpolynom,...
                calcmassaxis);
        
            plot(previewaxes,calcmassaxis,sumspectrum,'k--'); 
        end
        
        hold(previewaxes,'off');
        
        %Zoom data
        %[~,i]=max(handles.molecules{index}.peakdata(:,2));
        
        xlim(previewaxes,[xmin-1,xmax+1]);  
        %ylim(previewaxes,[0,max(max(handles.molecules{index}.peakdata(:,2)),max(handles.peakdata(handles.molecules{index}.minind:handles.molecules{index}.maxind,2)))]);
        
        guidata(Parent,handles);
    end

    function moleculepreview(hObject,eventdata)
        handles=guidata(hObject);
        sendertag=get(hObject,'Tag');
        
        clickedindex=get(hObject,'Value');
        
        switch sendertag
            case 'ListRelevantMolecules'
                rangeindex=get(ListRanges,'Value');
                moleculeindex=clickedindex;
                index=handles.ranges{rangeindex}.molecules{clickedindex}.rootindex;
                com=handles.ranges{rangeindex}.com;
                previewpaneledit('on');
            case 'ListRanges'
                rangeindex=clickedindex;
                moleculeindex=1;
                ranges2listbox(rangeindex,moleculeindex);
                set(ListRelevantMolecules,'Value',1);
                index=handles.ranges{clickedindex}.molecules{1}.rootindex;
                com=handles.ranges{clickedindex}.com; 
                previewpaneledit('on');
            otherwise
                index=clickedindex;
                previewpaneledit('off');
                com=handles.molecules{index}.com;
        end
             
        if sum(index==handles.calibrationlist)==0
            %guess resolution and massoffset
            currentmassoffset=polynomial(handles.massoffsetpolynom,handles.molecules{index}.com);
            currentresolution=polynomial(handles.resolutionpolynom,handles.molecules{index}.com);
        else
            currentmassoffset=handles.ranges{rangeindex}.massoffset;
            currentresolution=handles.ranges{rangeindex}.resolution;
        end
                
        area=handles.molecules{index}.area;
     

        guidata(hObject,handles);
        
        writetopreviewedit(com,currentmassoffset,currentresolution,area)
        plotpreview(index);
        
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

    function addtolist(hObject,eventdata)
        %adds marked element in moleculelistbox to calibration listbox
        
        handles=guidata(hObject);
        
        index=get(ListAllMolecules,'Value');
%       
        if sum(handles.calibrationlist==index)==1 %Already added
            msgbox('This Molecule is already in list!')
        else
            [handles.calibrationlist,ix]=sort([handles.calibrationlist index]);

            handles.ranges=findranges(handles.molecules(handles.calibrationlist));
            handles.ranges=addrangeparameters(handles.ranges,handles.massoffsetpolynom,handles.resolutionpolynom);
                        
            guidata(hObject,handles);
            
            [~, rangeindex, moleculeindex]=memberofrange(handles.ranges,index);
            
            ranges2listbox(rangeindex,moleculeindex);
            
            plotdatapoints();
            %set selection to recently added entry
            handles=guidata(hObject);
            
            previewpaneledit('on');
        end        
    end

    function removefromlist(hObject,eventdata)
        %removes marked element from calibration listbox
        
        handles=guidata(hObject);
        
        index=handles.ranges{get(ListRanges,'Value')}.molecules{get(ListRelevantMolecules,'Value')}.rootindex;
        
        handles.calibrationlist=handles.calibrationlist(handles.calibrationlist~=index);
        
        if ~isempty(handles.calibrationlist)
            handles.ranges=findranges(handles.molecules(handles.calibrationlist));
            handles.ranges=addrangeparameters(handles.ranges,handles.massoffsetpolynom,handles.resolutionpolynom);
        else
            handles.ranges={};
        end
        guidata(hObject,handles);
        
        ranges2listbox(1,1);

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
            
            temp='';
            for i=1:length(handles.ranges{rangeindex}.molecules)
                temp{i}=handles.ranges{rangeindex}.molecules{i}.name;
            end
            
            set(ListRelevantMolecules,'String',temp);
            set(ListRelevantMolecules,'Value',moleculeindex);
        else
            set(ListRanges,'String','');
            set(ListRanges,'Value',1);
            set(ListRelevantMolecules,'String','');
            set(ListRelevantMolecules,'Value',1);
        end
        
        guidata(Parent,handles);
    end

    function molecules2listbox(ListBox,list)
        handles=guidata(Parent);
        
        temp='';
        for i=1:length(list)  
            temp{i}=handles.molecules{list(i)}.name;
        end
        
        if length(temp)==0
            set(ListBox,'Value',1);
        end
        
        set(ListBox,'String',temp);
        
                
        guidata(Parent,handles);
    end

    function parameterchange(hObject,eventdata)
        handles=guidata(hObject);
        tag=get(hObject,'Tag');
        switch tag
            case 'massoffsetup'
                value=str2double(get(e_massoffset,'String'));
                value=value+0.1;
                set(e_massoffset,'String',num2str(value));
            case 'massoffsetdown'
                value=str2double(get(e_massoffset,'String'));
                value=value-0.1;
                set(e_massoffset,'String',num2str(value));
            case 'resolutionup'
                value=str2double(get(e_resolution,'String'));
                value=value+0.1*value;
                set(e_resolution,'String',num2str(value));
            case 'resolutiondown'
                value=str2double(get(e_resolution,'String'));
                value=value-0.1*value;
                set(e_resolution,'String',num2str(value));
            case 'areaup'
                value=str2double(get(e_area,'String'));
                value=value+0.1*value;
                set(e_area,'String',num2str(value));   
            case 'areadown'
                value=str2double(get(e_area,'String'));
                value=value-0.1*value;
                set(e_area,'String',num2str(value));                
        end
        guidata(hObject,handles);
        updatecurrentmolecule();
    end

%     function moleculepreview(hObject,eventdata)
%         handles=guidata(hObject);
%                 
%         guidata(hObject,handles);
%     end

  
end
