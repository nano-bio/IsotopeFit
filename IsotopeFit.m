function IsotopeFit()

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'IsotopeFit',...
    'Units','normalized',...
    'Position',[0.2,0.2,0.6,0.6]); 

% Display tags to read out handle:
%  hToolbar = findall(Parent,'tag','FigureToolBar');
%  get(findall(hToolbar),'tag')

% modify callbacks:
hTemp = findall(Parent,'tag','Standard.FileOpen');
set(hTemp, 'ClickedCallback',@open_file);

hTemp = findall(Parent,'tag','Standard.SaveFigure');
set(hTemp, 'ClickedCallback',@(a,b) save_file(a,b,'save'));

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

% ===== AXES ===== %

%Preview Panel

dataaxes = axes('Parent',Parent,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(64,64,35,62,2,54,0.04,0.02)); 

% Area Axes

areaaxes = axes('Parent',Parent,...
             'ActivePositionProperty','OuterPosition',...
             'ButtonDownFcn','disp(''axis callback'')',...
             'Units','normalized',...
             'Position',gridpos(64,64,1,32,10,54,0.04,0.02));
         
% ===== TOOLBAR LEFT OF AREA AXES ===== %

e_searchstring=uicontrol(Parent,'Style','edit',...
    'Tag','e_searchstring',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(64,64,30,32,1,7,0.01,0.01));         
         
uicontrol(Parent,'style','pushbutton',...
          'string','Sort List',...
          'Callback',@sortlistclick,...
          'Units','normalized',...
          'Position',gridpos(64,64,30,32,7,10,0.01,0.01));

ListSeries=uicontrol(Parent,'Style','Listbox',...
    'Units','normalized',...
    'Callback',@listseriesclick,...
    'Position',gridpos(64,64,1,30,1,10,0.01,0.01));

% ===== TOOLBAR ON THE RIGHT ===== %
    
uicontrol(Parent,'Style','Text',...
    'String','Molecules',...
    'Units','normalized',...
    'Position',gridpos(64,64,62,64,53,64,0.01,0.01));  

% Fun fact: Max is set to anything so that Max-Min is greater than one. If
% that is the case, Matlab lets you select more than one molecule. Note
% that the actual value of Max-Min does not indicate how many you actually
% can select.

ListMolecules=uicontrol(Parent,'Style','Listbox',...
    'Units','normalized',...
    'Callback',@moleculelistclick,...
    'Max', 3,...
    'Position',gridpos(64,64,17,61,53,64,0.01,0.01));

uicontrol(Parent,'style','pushbutton',...
          'string','Add Molecules',...
          'Callback','',...
          'Units','normalized',...
          'Position',gridpos(64,64,13,16,53,64,0.01,0.01));
      
% display for the mass of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Center of mass:',...
    'Units','normalized',...
    'Position',gridpos(64,64,11,13,53,58,0.01,0.01));

comdisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,11,13,58,64,0.01,0.01));

% display for the resolution of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Resolution:',...
    'Units','normalized',...
    'Position',gridpos(64,64,9,11,53,58,0.01,0.01));

resolutiondisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,9,11,58,64,0.01,0.01));

% display for the area of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Area:',...
    'Units','normalized',...
    'Position',gridpos(64,64,7,9,53,58,0.01,0.01));

areadisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,7,9,58,64,0.01,0.01));

% Now for the fit buttons:
      
uicontrol(Parent,'style','pushbutton',...
          'string','Fit all',...
          'Callback',@fitbuttonclick,...
          'Units','normalized',...
          'Position',gridpos(64,64,4,7,57,60,0.01,0.01));
      
uicontrol(Parent,'style','pushbutton',...
          'string','Fit selected',...
          'Callback',@fitbuttonclick,...
          'Units','normalized',...
          'Position',gridpos(64,64,4,7,53,57,0.01,0.01));
      
% Listbox for the fit method
      
ListMethode = uicontrol(Parent,'style','popupmenu',...
          'string',{'Ranges', 'Molecules'},...
          'Units','normalized',...
          'Position',gridpos(64,64,4,7,60,64,0.01,0.01));
      
% Autodetect peaks button
      
uicontrol(Parent,'style','pushbutton',...
          'string','Autodetect peaks',...
          'Callback',@showlargedeviations,...
          'Units','normalized',...
          'Position',gridpos(64,64,1,4,53,64,0.01,0.01));

% ===== FILENAME DISPLAY ON TOP ===== %

% The following two controls display the current filename on top of the
% window
          
uicontrol(Parent,'Style','Text',...
    'String','Filename:',...
    'Units','normalized',...
    'Position',gridpos(64,64,62,64,4,8,0.01,0.01));
    
filenamedisplay = uicontrol(Parent,'Style','Text',...
    'Units','normalized',...
    'String','No file loaded',...
    'HorizontalAlignment','left',...
    'Position',gridpos(64,64,62,64,8,50,0.01,0.01));

% This copies the filename to the clipboard (for searching in the
% labbook etc.

uicontrol(Parent,'style','pushbutton',...
          'string','Copy',...
          'Callback',@copyfntoclipboard,...
          'Units','normalized',...
          'TooltipString','Click to copy the filename to the clipboard',...
          'Position',gridpos(64,32,62,64,25,26,0.01,0.01));

% ===== GUI ELEMENTS TO CHANGE VIEW IN DATA AXES ===== %
      
% Toggle log scale for the data axes
      
uicontrol(Parent,'style','checkbox',...
          'string','Log',...
          'Callback',@togglelogscale,...
          'Value', 0,...
          'Units','normalized',...
          'TooltipString','Toggle log scale',...
          'Position',gridpos(64,64,32,34,1,4,0.01,0.01));
      
% Multiply y-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','*2',...
          'Callback',@doubleyscale,...
          'Units','normalized',...
          'TooltipString','Multiply axes by a factor of two',...
          'Position',gridpos(64,64,60,62,1,3,0.01,0.01));
      
% Divide y-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','/2',...
          'Callback',@halfyscale,...
          'Units','normalized',...
          'TooltipString','Divide axes by a factor of two',...
          'Position',gridpos(64,64,34,36,1,3,0.01,0.01));
      
% Autoscale y-axis
      
uicontrol(Parent,'style','pushbutton',...
          'string','Y',...
          'Callback',@autoyscale,...
          'Units','normalized',...
          'TooltipString','Autoscale axes',...
          'Position',gridpos(64,64,36,60,1,3,0.01,0.01));
      
% Divide x-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','/2',...
          'Callback',@halfxscale,...
          'Units','normalized',...
          'TooltipString','Multiply axes by a factor of two',...
          'Position',gridpos(64,64,32,34,4,6,0.01,0.01));
      
% Multiply x-axis by a factor of two
      
uicontrol(Parent,'style','pushbutton',...
          'string','*2',...
          'Callback',@doublexscale,...
          'Units','normalized',...
          'TooltipString','Divide axes by a factor of two',...
          'Position',gridpos(64,64,32,34,50,52,0.01,0.01));
      
% slider x-axis
      
dataxslider = uicontrol(Parent,'style','slider',...
          'string','/2',...
          'Callback',@slidedataaxes,...
          'Units','normalized',...
          'TooltipString','Slide along the mass spec',...
          'Position',gridpos(64,64,32,34,6,50,0.01,0.01));
      
% Plot overview
      
uicontrol(Parent,'style','pushbutton',...
          'string','OV',...
          'Callback',@plotoverview,...
          'Units','normalized',...
          'TooltipString','Plot whole mass spec (overview)',...
          'Position',gridpos(64,64,62,64,1,3,0.01,0.01));

%%
% ===== MENU BAR ===== %

mfile = uimenu('Label','File');
    %uimenu(mfile,'Label','Testdata','Callback',@test);
    uimenu(mfile,'Label','Open','Callback',@open_file,'Accelerator','O');
    uimenu(mfile,'Label','Save','Callback',@(a,b) save_file(a,b,'save'),'Accelerator','S');
    uimenu(mfile,'Label','Save as...','Callback',@(a,b) save_file(a,b,'saveas'));
    uimenu(mfile,'Label','Import from Labbook...','Callback',@labbookimport,...
        'Separator','on');
    uimenu(mfile,'Label','Recover file after crash','Callback',@recoverfile,...
        'Separator','on');
    uimenu(mfile,'Label','Edit Settings','Callback',@callsettings,...
        'Separator','on');
    uimenu(mfile,'Label','Quit','Callback','exit',... 
           'Separator','on','Accelerator','Q');
       
mmolecules= uimenu('Label','Molecules','Enable','off');
       uimenu(mmolecules,'Label','Load from folder...','Callback',@menuloadmoleculesfolder);
       uimenu(mmolecules,'Label','Load from ifd...','Callback',@menuloadmoleculesifd);
       
mcal= uimenu('Label','Calibration');
       mcalbgc=uimenu(mcal,'Label','Background correction...','Callback',@menubgcorrection,'Enable','off');
       mcalcal=uimenu(mcal,'Label','Mass- and Resolution calibration...','Callback',@menucalibration,'Enable','off');
       mloadcal=uimenu(mcal,'Label','Load calibration and molecules from ifd...','Callback',@menuloadcalibration,'Enable','on');
       mcaldc=uimenu(mcal,'Label','Drift correction...','Callback',@menudc,'Enable','on');
 
mdata= uimenu('Label','Export');
       uimenu(mdata,'Label','Cluster Series...','Callback',@menuexportdataclick,'Enable','on');
       uimenu(mdata,'Label','Current View...','Callback',@menuexportcurrentview,'Enable','on');
       uimenu(mdata,'Label','Calibrated Mass Spectrum...','Callback',@menuexportmassspec,'Enable','on');
       
       
mplay = uimenu('Label','Play');
    uimenu(mplay,'Label','Original','Callback',@menuplay,'Enable','on');
    uimenu(mplay,'Label','Fitted Data','Callback',@menuplay,'Enable','on');
       
%%       
% ===== END OF LAYOUT ===== %     
      
addpath('DERIVESTsuite');
addpath('FMINSEARCHBND');
addpath('IsotopeDistribution');

init();

    function init()
        %%
        handles=guidata(Parent);
        %bg correction standard values
        handles.bgcorrectiondata.startmass=-inf;
        handles.bgcorrectiondata.endmass=+inf;
        handles.bgcorrectiondata.ndiv=50;
        %handles.bgcorrectiondata.polydegree=3;
        handles.bgcorrectiondata.percent=70;
        %handles.bgcorrectiondata.bgpolynom=0;
        handles.bgcorrectiondata.bgm=[];
        handles.bgcorrectiondata.bgy=[];
        
        handles.peakdata=[];
        handles.raw_peakdata=[];
        
        %fileinfo standard values
        handles.fileinfo.originalfilename='';
        handles.fileinfo.filename='';
        handles.fileinfo.pathname=[pwd,'\'];
        
        %no molecules at start
        handles.molecules={};
        
        % some basic settings for the software
        handles.settings = settingswindow(Parent, 'nothing', 'read');
        
        % these variables represent values that are necessary for the
        % program to determine its current state.
        handles.status.logscale = 0;
        handles.status.overview = 0;
        handles.status.lastlims = [[0 0] [0 0]];
        
        %initial calibration data
        handles.calibration=standardcalibration();
        
        guidata(Parent,handles);
    end

    function peakdataout=approxpeakdata(peakdata,samplerate)
        %this function resamples the peakdata with a given, equidistant
        %samplerate (i.e. 0.1 massunits)
        l=size(peakdata,1);
        
        %% massaxis needs to be smooth for resampling
        mass=spline(1:round(l/1000):l,peakdata(1:round(l/1000):l,1)',1:l);
        
       %% sometimes, the spectrum isnt incrasing at the begininng. cut out
       % this region
       ind=find(diff(mass)<=0);
       
       if ~isempty(ind)
           ind=ind(end)+1;
       else
           ind=1;
       end
       
       %% resampling
       mt=mass(ind):samplerate:mass(end);
       peakdataout=[mt',...
                    double(interp1(mass(ind:end),peakdata(ind:end,2)',mt))'];
    end

    function menuexportmassspec(hObject,~)
        %% Exports Peakdata + fitted curves of current plot to ascii file
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export Mass Spectrum');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            handles=guidata(hObject);
           
            %write title line
            fid=fopen(fullfile(pathname,filename),'w');
            fprintf(fid,'Mass (Dalton)\tSignal (a.u.)\n');
            fclose(fid);

            %append data
            dlmwrite(fullfile(pathname,filename),handles.peakdata,'-append','delimiter','\t','precision','%e');
        end
    end

    function menuexportcurrentview(hObject,~)
        %% Exports Peakdata + fitted curves of current plot to ascii file
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            fid=fopen(fullfile(pathname,filename),'w');
            handles=guidata(hObject);
            limits= get(dataaxes, 'XLim');
            
            %find molecules that are in current view
            moleculelist=molecules_in_massrange(handles.molecules,limits(1),limits(2));
            minind=mass2ind(handles.peakdata(:,1)',limits(1));
            maxind=mass2ind(handles.peakdata(:,1)',limits(2));
            
            massaxis=handles.peakdata(minind:maxind,1)';
            resolutionaxis=resolutionbycalibration(handles.calibration,massaxis);
            
            fitted_data=zeros(length(massaxis),length(moleculelist));
            k=1;
            
            %write ascii data
            fprintf(fid,'Massaxis\tOrig. Signal\tFitted Signal');
            
            %read out molecule data and write names to first line
            for i=moleculelist
                %calculate fitted data for every molecule:
                fitted_data(:,k)=multispec(handles.molecules(i),resolutionaxis,0,massaxis)';
                k=k+1;
                %write name of molecule
                fprintf(fid,'\t%s',handles.molecules{i}.name);
            end
            fprintf(fid,'\n');
            fclose(fid);
            
            %append data matrix to ascii file
            dlmwrite(fullfile(pathname,filename),[handles.peakdata(minind:maxind,:),sum(fitted_data,2),fitted_data],'-append','delimiter','\t','precision','%e');
        end
    end
    
    function callsettings(hObject, eventdata)
        handles=guidata(hObject);
        % the last parameter doesn't really matter, as long it isn't 'read'
        % because that doesn't show the window
        handles.settings = settingswindow(hObject, eventdata, 'show');
        guidata(Parent,handles);
    end

    function menuplay(hObject,~)

       handles=guidata(hObject);

       h = figure('units','pixels','Name','Clustersound','NumberTitle', 'off','position',[500 500 200 50],'windowstyle','modal');
        uicontrol('style','text','string',sprintf('Yeah, Groovy!\nI''ll prepare the data for you...'),'units','pixels','position',[10 10 180 30]);
       drawnow;

       %h=msgbox('Yeah, Groovy! I''ll prepare the Data...');

       sample=0.1;
       onemassfreq=800; %Hz for peaks with deltam=1

       %mass values need to be distinct:
       l=size(handles.peakdata,1);

       mass=spline(1:round(l/1000):l,handles.peakdata(1:round(l/1000):l,1)',1:l);

       %sometimes, the spectrum isnt incrasing at the begininng. cut out
       %this region
       ind=find(diff(mass)<=0);

       if ~isempty(ind)
           ind=ind(end)+1;
       else
           ind=1;
       end

       %mass=mass(ind,end);


       t=handles.peakdata(ind,1):sample:handles.peakdata(end,1);

       %plot(dataaxes,diff(mass));
       f=onemassfreq/sample;

       switch get(hObject,'Label')
           case 'Original'
               spec=double(interp1(mass(ind:end),handles.peakdata(ind:end,2)',t));
               spec(isnan(spec))=0;
           case 'Fitted Data'
               spec=multispec(handles.molecules,3000,0,t);
       end

       spec=smooth(spec,10);

       spec=log(spec-min(spec)+0.1);       
       spec=spec-mean(spec);

       spec=spec/max(abs(spec));
       dspec=diff(spec);
       dspec=dspec/max(abs(dspec));


       plot(dataaxes,t,spec);

       %plot(dataaxes,t(1:end-1),dspec);
       close(h);
       sound(dspec,f);
    end
    
    function menudc(hObject,~)
        handles = guidata(Parent);
        listindices = get(ListMolecules,'Value');
        something = driftcorrection(handles, listindices);
    end

    function labbookimport(hObject,~)
        [pathname,filename]=readfromlabbook();
        
        if ~strcmp(filename,'')
            set(mmolecules,'Enable','on');
            load_h5(pathname,filename);
            handles=guidata(Parent);
            plot(dataaxes,handles.peakdata(:,1),handles.peakdata(:,2));
            
            %write filename to visible display:
            set(filenamedisplay, 'String', handles.fileinfo.originalfilename);
        end
    end

    function recoverfile(hObject,eventdata)
        % This function checks for the existance of a file called bkp.ifd
        % in the same folder as the the program. This file is usually
        % created before the "Fit All" routine is carried out and deleted
        % afterwards (in order to protect the data in case the fitting
        % routine runs into trouble). If it exists, it's being loaded.
        filename = 'bkp.ifd';
        pathname = pwd;
        fullpath = fullfile(pathname, filename);
        
        % actually there?
        if exist(filename, 'file') == 2
            open_file(hObject, eventdata, fullpath);
        else % nope
            msgbox('No backup file found.');
        end
    end
    
    function menuexportdataclick(hObject,~)
        handles=guidata(hObject);

        searchstring=get(e_searchstring,'String');        
        [handles.seriesarea,handles.seriesareaerror,serieslist]=sortmolecules(handles.molecules,searchstring,handles.peakdata);
        guidata(hObject,handles);
        
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data');
        handles=guidata(Parent);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            fid=fopen(fullfile(pathname,filename),'w');
            
            fprintf(fid,'\t');
            for i=1:length(serieslist)
                fprintf(fid,'%s\t(error)\t',serieslist{i});
            end
            fprintf(fid,'\n');
            %size(handles.seriesarea,1)
            for i=1:size(handles.seriesarea,1)
                fprintf(fid,'%i\t',i-1);
                for j=1:size(handles.seriesarea,2)
                    fprintf(fid,'%e\t%e\t',handles.seriesarea(i,j),handles.seriesareaerror(i,j));
                end
                fprintf(fid,'\n');
            end
        end
    end

    function listseriesclick(hObject,~)
        handles=guidata(hObject);

        ix=get(ListSeries,'Value');
        
        j=1;
        for i=1:size(handles.seriesarea,1)
            if (handles.seriesarea(i,ix)~=0)||(handles.seriesareaerror(i,ix)~=0)
                n(j)=i-1;
                data(j)=handles.seriesarea(i,ix);
                dataerror(j)=handles.seriesareaerror(i,ix);
                j=j+1;
            end
        end
        
        
        %area(areaaxes,n,data+dataerror,data-dataerror,'Facecolor',[0.7,0.7,0.7],'Linestyle','none');
        
        plot(areaaxes,n,data,'k--');
        hold on;
        
        stem(areaaxes,n,data,'filled','+k'); 
        
        stem(areaaxes,n,data+dataerror,'Marker','v','Color','b','LineStyle','none');
        stem(areaaxes,n,data-dataerror,'Marker','^','Color','b','LineStyle','none');
        
        hold off;
        
       % imagesc(log(handles.seriesarea)');

        guidata(hObject,handles);
        
%        set(ListSeries,'String',serieslist);
        
    end

    function sortlistclick(hObject,~)
        handles=guidata(hObject);
        
        searchstring=get(e_searchstring,'String');        
        [handles.seriesarea,handles.seriesareaerror,serieslist]=sortmolecules(handles.molecules,searchstring,handles.peakdata);
        guidata(hObject,handles);
        
        set(ListSeries,'Value',1);
        set(ListSeries,'String',serieslist);
        
    end

    function calibrationmenu(value1,value2)
        set(mcalbgc,'Enable',value1);
        set(mcalcal,'Enable',value2);
    end

    function menuloadmoleculesfolder(hObject,~)
        handles=guidata(Parent);
        folder=uigetdir();
        
        if length(folder)>1 %cancel returns folder=0
            handles.molecules=loadmolecules(folder,foldertolist(folder),handles.peakdata);
            guidata(Parent,handles);
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        calibrationmenu('on','on');
    end

    function menuloadmoleculesifd(hObject,~)
        handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.ifd','IsotopeFit data file (*.ifd)'},...
            'Open IsotopeFit data file');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            data={}; %load needs a predefined variable
            load(fullfile(pathname,filename),'-mat');
            
            handles.molecules=data.molecules;
            
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end
        calibrationmenu('on','on');
    end

    function menuloadcalibration(hObject,~)
        handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.ifd','IsotopeFit data file (*.ifd)'},...
            'Open IsotopeFit data file');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            data={}; %load needs a predefined variable
            load(fullfile(pathname,filename),'-mat');
            
            % Background correction data
            handles.bgcorrectiondata=data.bgcorrectiondata;
            
            if ~isfield(handles.bgcorrectiondata,'bgm') %compatibility: old bg correction methode
                handles.bgcorrectiondata.bgm=[];
                handles.bgcorrectiondata.bgy=[];
            end
            
            handles.molecules=data.molecules;
            
            %Calibration data
            handles.calibration=data.calibration;
            
            handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
            handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
            handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
            
            
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end
        calibrationmenu('on','on');
    end

    function menubgcorrection(hObject,~)
        handles=guidata(Parent);
        [handles.bgcorrectiondata, handles.startind, handles.endind]=bg_correction(handles.raw_peakdata,handles.bgcorrectiondata);    
        handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
        handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
        guidata(Parent,handles);
    end

    function menucalibration(hObject,~)
        handles=guidata(Parent);
        
        peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
        peakdata=subtractbg(peakdata,handles.bgcorrectiondata);
        
        [handles.calibration,handles.molecules]= calibrate(peakdata,handles.molecules,handles.calibration,handles.settings);
            
        
        handles.peakdata=subtractmassoffset(peakdata,handles.calibration);
        guidata(Parent,handles);
    end

    function load_h5(pathname,filename)
        init();
        handles=guidata(Parent);
        mass = h5read(fullfile(pathname,filename),'/FullSpectra/MassAxis');
        signal = h5read(fullfile(pathname,filename),'/FullSpectra/SumSpectrum');
        handles.raw_peakdata=[mass,signal];
        handles.startind=1;
        handles.endind=size(handles.raw_peakdata,1);
        handles.peakdata=handles.raw_peakdata;
        
        handles.calibration=standardcalibration;
        
        handles.fileinfo.originalfilename=filename(1:end-3);
        handles.fileinfo.pathname=pathname;
        
        % we need this if want to access the h5 file later for drift
        % correction. Note this might differ later from the pathname and
        % filename, once the data is saved as an idf-file.
        handles.fileinfo.h5completepath = fullfile(pathname,filename);
        
        guidata(Parent,handles);
        calibrationmenu('on','off');
    end

    function load_ascii(pathname,filename)
        init();
        handles=guidata(Parent);
        handles.raw_peakdata = load(fullfile(pathname,filename));
        
        handles.startind=1;
        handles.endind=size(handles.raw_peakdata,1);
        handles.peakdata=handles.raw_peakdata;
        
        handles.calibration=standardcalibration;
        
        handles.fileinfo.originalfilename=filename(1:end-4);
        handles.fileinfo.pathname=pathname;
        
        guidata(Parent,handles);
        calibrationmenu('on','off');
    end

    function open_file(hObject, ~, fullpath)
        % most likely this function will not retrieve filename or pathname
        % in this case we show a selection dialog.

        if ~exist('fullpath', 'var')
            [filename, pathname, filterindex] = uigetfile( ...
                {'*.ifd','IsotopeFit data file (*.ifd)';...
                '*.h5','HDF5 data file (*.h5)';...
                '*.h5;*.ifd;*.txt','All files suitable';...
                '*.*','ASCII data file (*.*)'},...
                'Open IsotopeFit data file');
        % if we indeed got a filename to load, we just set the filterindex
        % to the file suffix
        else
            [pathname, filename, suffix] = fileparts(fullpath);
            if strcmp(suffix, '.ifd')
                filterindex = 1;
            elseif strcmp(suffix, '.h5')
                filterindex = 2;
            else % assume it's ASCII
                filterindex = 3;
            end
            filename = [filename, suffix];
        end
        
        % before we load the file we clear all listboxes and plots
        clearall();
        
        handles=guidata(Parent);
        if ~(isequal(filename,0) || isequal(pathname,0))
            set(mmolecules,'Enable','on');
            switch filterindex
                case 1 %ifd
                    data={}; %load needs a predefined variable
                    load(fullfile(pathname,filename),'-mat');
                    
                    handles.raw_peakdata=data.raw_peakdata;
                    %handles.bgpolynom=data.bgpolynom;
                    handles.startind=data.startind;
                    handles.endind=data.endind;

                    % Background correction data
                    handles.bgcorrectiondata=data.bgcorrectiondata;
                    
                    if ~isfield(handles.bgcorrectiondata,'bgm') %compatibility: old bg correction methode
                        handles.bgcorrectiondata.bgm=[];
                        handles.bgcorrectiondata.bgy=[];
                    end
                    
                    handles.molecules=data.molecules;
                    
                    %Calibration data
                    handles.calibration=data.calibration;
                    
                    handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
                    handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
                    handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
                    
                    handles.fileinfo.filename=filename;
                    handles.fileinfo.originalfilename=filename(1:end-4);
                    handles.fileinfo.pathname=pathname;
                    
                    guidata(Parent,handles);
                    
                    molecules2listbox(ListMolecules,handles.molecules);
                    
                    calibrationmenu('on','on');
                case 2 %h5
                    load_h5(pathname,filename);
                case 3 %ASCII
                    load_ascii(pathname,filename);
            end
            handles=guidata(Parent);
            plot(dataaxes,handles.peakdata(:,1),handles.peakdata(:,2));
            
            %write filename to visible display:
            set(filenamedisplay, 'String', handles.fileinfo.originalfilename)
        end
    end

    function out=standardcalibration()
        out.comlist=[];
        out.massoffsetlist=[];
        out.resolutionlist=[];
        out.massoffsetmethode='Flat';
        out.resolutionmethode='Flat';
        out.massoffsetparam=0; %dont care for spline or pchip
        out.resolutionparam=3000; %flat calibration
        out.namelist={};
    end

    function save_file(hObject, ~, methode)
        handles=guidata(Parent);
        
        if strcmp(methode,'saveas')||strcmp(handles.fileinfo.filename,'')
            [filename, pathname, ~] = uiputfile( ...
                {'*.ifd','IsotopeFit data file (*.ifd)'
                '*.*', 'All Files (*.*)'},...
                'Save as',[handles.fileinfo.pathname,handles.fileinfo.originalfilename,'.ifd']);
        elseif strcmp(methode,'autosave')
            pathname = '';
            filename = 'bkp.ifd';
        else
            filename=handles.fileinfo.filename;
            pathname=handles.fileinfo.pathname;  
        end
        
        
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            
            
            data.raw_peakdata=handles.raw_peakdata;
            data.startind=handles.startind;
            data.endind=handles.endind;
            data.molecules=handles.molecules;
            data.calibration=handles.calibration;
            data.bgcorrectiondata=handles.bgcorrectiondata;
            
            save(fullfile(pathname,filename),'data');
            
            % if we autosaved, we don't want that temporary filename to be
            % stored
            if ~strcmp(methode,'autosave')
                handles.fileinfo.filename=filename;
                handles.fileinfo.pathname=pathname;
            end
            
            guidata(Parent,handles);
         end
         
        %write filename to visible display:
        set(filenamedisplay, 'String', handles.fileinfo.filename)
    end

    function moleculelistclick(hObject,~)
        handles=guidata(Parent);
        
        index = get(ListMolecules,'Value');
        
        % we can always only plot one molecule. if several have been
        % selected we just plot the first one
        if (length(index) >= 2)
            index = index(1);
        end
        
        % plot the molecule
        plotmolecule(index);
        
        % set the displays
        % note this is not the nominal mass
        set(comdisplay, 'String', num2str(handles.molecules{index}.com));
        set(areadisplay, 'String', num2str(handles.molecules{index}.area));
        res = resolutionbycalibration(handles.calibration,handles.molecules{index}.com);
        set(resolutiondisplay, 'String', num2str(res));
    end

    function plotmolecule(index)
        handles=guidata(Parent);

    % find min and max index of mass range that should be plotted i.e.
    % certain range (30 sigma) around the selected molecules
        ind = findmassrange(handles.peakdata(:,1)',handles.molecules(index),resolutionbycalibration(handles.calibration,handles.molecules{index}.com),0,30);
        
    % corresponding mass values of axis
        calcmassaxis=handles.peakdata(ind,1)';
        
        resolutionaxis=resolutionbycalibration(handles.calibration,calcmassaxis);
        
    % calculate fitted spec for 1 (chosen) molecule
        calcsignal=multispec(handles.molecules(index),...
            resolutionaxis,...
            0,...
            calcmassaxis);
        
    % plot data (= calibrated raw data)
        plot(dataaxes,handles.peakdata(:,1)',handles.peakdata(:,2)','Color',[0.5 0.5 0.5]);
        hold(dataaxes,'on');
        
    % plot fitted data for all peaks that are displayed (need to find out which molecules are involved in this range) 
        limits = [calcmassaxis(1) calcmassaxis(end)];
        involvedmolecules=molecules_in_massrange(handles.molecules, limits(1), limits(2));
        
    % calculated fitted spec for all involved molecules
        sumspectrum=multispec(handles.molecules(involvedmolecules),...
            resolutionaxis,...
            0,...
            calcmassaxis);
        
        plot(dataaxes,calcmassaxis,sumspectrum,'k--','Linewidth',2); 
        plot(dataaxes,calcmassaxis,calcsignal,'Color','red'); 
   
        %calculate and plot sum spectrum of involved molecules if current
        %molecule is in calibrationlist
        
        % set semilog plot if necessary
        if (handles.status.logscale == 1)
            set(dataaxes, 'YScale', 'log');
        elseif (handles.status.logscale == 0)
            set(dataaxes, 'YScale', 'linear');
        end

        hold(dataaxes,'off');
        
        %Zoom data
        %[~,i]=max(handles.molecules{index}.peakdata(:,2));
 %       calcmassaxis
        xlim(dataaxes,[calcmassaxis(1),calcmassaxis(end)]);  
        %ylim(previewaxes,[0,max(max(handles.molecules{index}.peakdata(:,2)),max(handles.peakdata(handles.molecules{index}.minind:handles.molecules{index}.maxind,2)))]);

        % Update the slider bar accordingly:
        updateslider;
        
        guidata(Parent,handles);
    end

    function out=croppeakdata(peakdata,ix1,ix2)
        out=peakdata(ix1:ix2,:);
    end

    function out=subtractbg(peakdata,bgcorrectiondata)
        out=peakdata;
        %out(:,2)=out(:,2)-polynomial(bgpolynom,peakdata(:,1));
        if length(bgcorrectiondata.bgm)>1
            out(:,2)=out(:,2)-interp1(bgcorrectiondata.bgm',bgcorrectiondata.bgy',peakdata(:,1),'pchip','extrap');
        end
    end

    function out=subtractmassoffset(peakdata,calibration)
        out=peakdata;
        mo=massoffsetbycalibration(calibration,peakdata(:,1));

        out(:,1)=out(:,1)-mo;
    end
    
    function [areaout,areaerrorout,sortlist]=sortmolecules(molecules,searchstring,peakdata)
        searchstring=['[' searchstring ']'];
        
        attached={};
        for i=1:length(molecules)
            name=[molecules{i}.name '['];
            %find lineindex
            ix=strfind(name,searchstring);
            if isempty(ix)
                lineix=1;
                num='';
            else
                j=ix+length(searchstring);
                num='';
                while name(j)~='['
                    num=[num name(j)];
                    j=j+1;
                end
                if isempty(num)
                    lineix=2;
                else
                    lineix=str2double(num)+1;
                end
            end
            %find rowindex
            name=strrep(name,[searchstring num],'');
            ix=getnameidx(attached,name);
            if ix==0 %not found
                rowix=length(attached)+1;
                attached{rowix}=name;
            else
                rowix=ix;
            end
            %We need to correct the area to get the number of ions detected
            %in this massrange. This can be approx. done by dividing the
            %area by the mean pin-distance. the smaller the msq of delta m,
            %the better the approximation...
            
%           Division by mean-pin-distance
%           npins=mass2ind(peakdata(:,1)',molecules{i}.maxmass)-mass2ind(peakdata(:,1)',molecules{i}.minmass); %number of pins
%           b=(molecules{i}.maxmass-molecules{i}.minmass)/npins; %mean pin-distance
           
%           dividion by sqrt(m):
            b=sqrt(molecules{i}.com);
     
            areaout(lineix,rowix)=molecules{i}.area/b;
            areaerrorout(lineix,rowix)=molecules{i}.areaerror/b;
        end
        for i=1:length(attached)
            sortlist{i}=[searchstring 'n' attached{i}(1:end-1)];
        end
    end

    function fitbuttonclick(hObject,eventdata)
        handles=guidata(hObject);
        
        % indices for all molecules selected
        index=get(ListMolecules,'Value');
        
        deltar=handles.settings.deltaresolution/100;
        deltam=handles.settings.deltamass;
        
        %be careful: don't double-calibrate masses!
        %set massoffset to zero for final fitting:
        calibrationtemp=handles.calibration;
        calibrationtemp.massoffsetmethode='Flat';
        calibrationtemp.massoffsetparam=0;
        
        %peakdatatemp=approxpeakdata(handles.peakdata,0.2);%much faster with lower resolution
        peakdatatemp=handles.peakdata;%full resolution
        
        switch get(hObject,'String')
            case 'Fit all'
                % in the case of Fit all we save the file. it's better to
                % be safe than sorry.
                save_file(hObject,eventdata,'autosave')
                
                handles.molecules=fitwithcalibration(handles.molecules,peakdatatemp,calibrationtemp,get(ListMethode,'Value'),handles.settings.searchrange,deltam,deltar,'linear_system');
                
                % and we're done
                delete('bkp.ifd')
            case 'Fit selected'
                %index consists of a list of molecules.
                %for fitting, we need to find all molecules that overlap
                %with the selected ones
                allinvolved=findinvolvedmolecules(handles.molecules,1:length(handles.molecules),index,handles.settings.searchrange,handles.calibration);
                
                handles.molecules(allinvolved)=fitwithcalibration(handles.molecules(allinvolved),peakdatatemp,calibrationtemp,get(ListMethode,'Value'),handles.settings.searchrange,deltam,deltar,'linear_system');
        end
        
        guidata(hObject,handles);
        
        % in order to plot we call moleculelistclick, because this function
        % plots and updates all the labels!
        moleculelistclick();
    end

    function showlargedeviations(hObject, ~)
        handles=guidata(Parent);

        % we check for a background level in the mass range between 2.1 and
        % 3.9 amu. subsequently we search through backdata that is above
        % the aforementioned background level.
        bg_area = find(handles.peakdata(:,1) < 3.9 & handles.peakdata(:,1) < 2.1);
        noise_threshold = mean(handles.peakdata(bg_area,2));
        possible_peak_areas = find(handles.peakdata(:,2) > noise_threshold);
        
        % we now have a lot of indices of points that are significantly 
        % higher than noise. we are looking for consecutive points in order
        % to avoid spikes. therefore we take the derivative and look for
        % gaps (= values ~= 1)
        deriv = diff(possible_peak_areas);
        pair = [1 0];
        stack = [];
        for i=1:length(deriv)
            if deriv(i) > 1
                pair(2) = possible_peak_areas(i);
                stack = [stack; pair];
                pair = [possible_peak_areas(i+1) 0];
            end
        end
        
        % now it is time to get the original points (in the mass range) and
        % plots some nice red rectangle for the hardworking PhD-student
        % to check out!
        % additionally, we check if the ranges are at least 
        % handles.settings.minpeakwidth amu broad
        sections_masses = [];
        for i = 1:size(stack, 1)
            % transform to mass range
            xstart = handles.peakdata(stack(i,1),1);
            xend = handles.peakdata(stack(i,2),1);
            new_section = [xstart, xend];
            if ((new_section(2) - new_section(1)) > handles.settings.minpeakwidth)
                sections_masses = [sections_masses; new_section];
            end
        end

        % we need y-values for drawing. we always paint across the whole
        % axes (in y-direction)
        ylim = get(dataaxes, 'YLim');
        
        % time to draw
        for i = 1:length(sections_masses)
            p = patch([sections_masses(i,1) sections_masses(i,1) sections_masses(i,2) sections_masses(i,2)],...
                      [ylim(1) ylim(2) ylim(2) ylim(1)],...
                      'r',...
                      'Parent', dataaxes);
            set(p,'FaceAlpha',0.4, 'EdgeColor', 'none', 'Parent', dataaxes);
        end
        guidata(Parent,handles);
    end

    function copyfntoclipboard(hObject, ~)
        % This copies the filename to the clipboard (for searching in the
        % labbook etc.
        fn = get(filenamedisplay, 'String');
        clipboard('copy', fn);
    end

    function togglelogscale(hObject, ~)
        % This button toggles the logarithmic display of the data axes in
        % y-direction.
        
        % get settings
        handles = guidata(Parent);
        
        % turn warning about negative values off
        warning('off', 'MATLAB:Axes:NegativeDataInLogAxis')
        
        % toggle function
        if (get(hObject,'Value') == get(hObject,'Max'))
            set(dataaxes, 'YScale', 'log');
            handles.status.logscale = 1;
        elseif (get(hObject,'Value') == get(hObject,'Min'))
            set(dataaxes, 'YScale', 'linear');
            handles.status.logscale = 0;
        end
        
        % save back
        guidata(Parent,handles);
    end

    function doubleyscale(hObject, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(dataaxes, 'YLim');
        % multiply
        nl = [cl(1)*2 cl(2)*2];
        % set back
        set(dataaxes, 'YLim', nl)
    end

    function doublexscale(hObject, ~)
        % This function multiplies the Y-axis with a factor of two (hence
        % making the signals smaller)
        
        % current limits
        cl = get(dataaxes, 'XLim');
        %half width to add
        hw = (cl(2)-cl(1))/2;
        % add
        nl = [cl(1)-hw cl(2)+hw];
        % set back
        set(dataaxes, 'XLim', nl);
        
        updateslider;
    end

    function halfyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(dataaxes, 'YLim');
        % divide
        nl = [cl(1)/2 cl(2)/2];
        % set back
        set(dataaxes, 'YLim', nl)
    end

    function halfxscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % current limits
        cl = get(dataaxes, 'XLim');
        % quarter width to add
        hw = (cl(2)-cl(1))/4;
        % add
        nl = [cl(1)+hw cl(2)-hw];
        % set back
        set(dataaxes, 'XLim', nl);
        
        updateslider;
    end

    function autoyscale(hObject, ~)
        % This function divides the Y-axis by a factor of two (hence
        % making the signals bigger)
        
        % set back
        set(dataaxes, 'YLimMode', 'auto');
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
        xlims = get(dataaxes, 'XLim');
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

    function slidedataaxes(hObject, ~)
        % This function updates the data axes when the slider for the
        % x-axis is clicked
        
        % calculate where around we are centered
        cl = get(dataaxes, 'XLim');
        % we need to add / substract half of the currently viewed range to
        % the new center of mass
        vrhalf = (cl(2) - cl(1))/2;
        
        % get center of mass
        com = get(dataxslider, 'Value');
        
        % new viewing range
        nl = [com-vrhalf com+vrhalf];
        % jump by one view range
        set(dataaxes, 'XLim', nl);
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
        cl = get(dataaxes, 'XLim');
        viewedrange = (cl(2) - cl(1))*2;
        
        maxmass = max(handles.peakdata(:,1));
        
        if (viewedrange <= maxmass && handles.status.overview == 1)
            handles.status.overview = 0;
        end
        
        % are we already in overview?
        if handles.status.overview == 0
            % save the old settings so we can toggle back
            oxl = get(dataaxes, 'XLim');
            oyl = get(dataaxes, 'YLim');
            handles.status.lastlims = [oxl oyl];
            set(dataaxes, 'YLimMode', 'auto');
            set(dataaxes, 'XLimMode', 'auto');
            handles.status.overview = 1;
        elseif handles.status.overview == 1
            % jump back to last settings
            handles.status.lastlims;
            set(dataaxes, 'XLim', [handles.status.lastlims(1) handles.status.lastlims(2)]);
            set(dataaxes, 'YLim', [handles.status.lastlims(3) handles.status.lastlims(4)]);
            handles.status.overview = 0;
        end
        
        % save back
        guidata(Parent,handles);
    end

    function clearall()
        % this function clears everything and is supposed to be called when
        % a new file is loaded.
        
        % clear plots
        cla(dataaxes);
        cla(areaaxes);
        
        % empty molecule list
        set(ListMolecules,'Value',1);
        set(ListMolecules,'String','');
        
        % clear series list
        set(ListSeries,'Value',1);
        set(ListSeries,'String','');
        
        % this sets default values to begin with
        init();
    end
end