function IsotopeFit()

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'IsotopeFit',...
    'Units','normalized',...
    'CloseRequestFcn',@closeandsave,...
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

% for backwards compatibility with the existing code, we map updateslider
% to the function inside the dataviewer object
dvhandle = dataviewer(Parent, gridpos(64,64,33,62,1,54,0.025,0.01), 50, 29, true);
dataaxes = dvhandle.axes;
updateslider = dvhandle.updateslider;

% Area Axes

tmp = dataviewer(Parent, gridpos(64,64,1,32,10,54,0.025,0.03), 50, 29, false);
areaaxes = tmp.axes;
         
% ===== TOOLBAR LEFT OF AREA AXES ===== %

e_searchstring=uicontrol(Parent,'Style','edit',...
    'Tag','e_searchstring',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Enable','on',...
    'Callback',@sortlistclick,...
    'Position',gridpos(64,64,30,32,1,7,0.01,0.01));         
         
uicontrol(Parent,'style','pushbutton',...
          'string','Sort List',...
          'Callback',@sortlistclick,...
          'Units','normalized',...
          'Position',gridpos(64,64,30,32,7,10,0.01,0.01));

ListSeries=uicontrol(Parent,'Style','Listbox',...
    'Units','normalized',...
    'Callback',@listseriesclick,...
    'Max',3,...             % necessary to make it possible to select 
    'Min',1,...             % more than 1 cluster series in list
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
    'Position',gridpos(64,64,18,61,53,64,0.01,0.01));

ListFilter = uicontrol(Parent,'Style','edit',...
    'String','',...
    'Units','normalized',...
    'Callback',@filterListMolecules,...
    'Position',gridpos(64,64,16,18,53,61,0.01,0.01));

uicontrol(Parent,'style','pushbutton',...
    'string','Filter',...
    'Callback',@filterListMolecules,...
    'Units','normalized',...
    'Position',gridpos(64,64,16,18,61,64,0.01,0.01));

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
    msave = uimenu(mfile,'Label','Save','Callback',@(a,b) save_file(a,b,'save'),'Accelerator','S');
    msaveas = uimenu(mfile,'Label','Save as...','Callback',@(a,b) save_file(a,b,'saveas'));
    uimenu(mfile,'Label','Import from Labbook...','Callback',@labbookimport,...
        'Separator','on');
    uimenu(mfile,'Label','Recover file after crash','Callback',@recoverfile,...
        'Separator','on');
    uimenu(mfile,'Label','Edit Settings','Callback',@callsettings,...
        'Separator','on');
    uimenu(mfile,'Label','Quit','Callback','exit',... 
           'Separator','on','Accelerator','Q');
       
mmolecules = uimenu('Label','Molecules','Enable','off');
       uimenu(mmolecules,'Label','Load from folder...','Callback',@menuloadmoleculesfolder);
       uimenu(mmolecules,'Label','Load from ifd...','Callback',@menuloadmoleculesifd);
       uimenu(mmolecules,'Label','Load from ifm...','Callback',@menuloadmoleculesifm);
       
mcal = uimenu('Label','Calibration');
       mcalbgc=uimenu(mcal,'Label','Background correction...','Callback',@menubgcorrection,'Enable','off');
       mcalcal=uimenu(mcal,'Label','Mass- and Resolution calibration...','Callback',@menucalibration,'Enable','off');
       mloadcal=uimenu(mcal,'Label','Load calibration and molecules from ifd...','Callback',@menuloadcalibration,'Enable','on');
       mcaldc=uimenu(mcal,'Label','Drift correction...','Callback',@menudc,'Enable','on');
 
mdata = uimenu('Label','Export');
       mdatacs = uimenu(mdata,'Label','Cluster Series...','Callback',@menuexportdataclick,'Enable','on');
       mdatacv = uimenu(mdata,'Label','Current View...','Callback',@menuexportcurrentview,'Enable','on');
       mdatacms = uimenu(mdata,'Label','Calibrated Mass Spectrum...','Callback',@menuexportmassspec,'Enable','on');
       
       
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
        
        handles.status.moleculesfiltered = 0;
        
        handles.status.guistatusvector = [0 0 0 0 0 0];

        %initial calibration data
        handles.calibration=standardcalibration();
        
        guidata(Parent,handles);
        
        gui_status_update();
    end

    function gui_status_update(statusvariable, value)
        % This function updates the availability of GUI elements according
        % certain states of the evaluation. E.g. a mass spec can only be
        % calibrated if molecules have been loaded. It either takes no
        % argument and then updates all GUI elements according to the
        % status vector handles.status.guistatusvector or it takes two
        % arguments:
        % statusvariable -> state to be changed
        % value -> value (0|1) for the given state
        % for a list of possible statusvariables, see the variable 
        % statusvectortemplate
        
        % load handles with status vector
        handles=guidata(Parent);
        
        % possible status elements
        statusvectortemplate = {'file_loaded',...
            'molecules_loaded',...
            'calibrated',...
            'bg_corrected',...
            'drift_corrected',...
            'changed'};
        
        % list of gui elements that should be hidden/shown
        guielements = {'mcalbgc', 'mcalcal', 'mloadcal', 'mcaldc', 'mmolecules', 'mcal', 'msave', 'msaveas', 'mplay', 'mdata', 'mdatacms'};
        % according requirement list. each entry in each vector corresponds
        % to one of the states defined above
        guirequirements = {[1 0 0 0 0 0], [1 1 0 0 0 0], [1 0 0 0 0 0], [1 1 1 0 0 0], [1 0 0 0 0 0], [1 0 0 0 0 0], [1 0 0 0 0 0], [1 0 0 0 0 0], [1 0 0 0 0 0], [1 0 0 0 0 0], [1 1 1 0 0 0]};
        
        if nargin > 1
            % we want to update the status vector
            
            % which element in the vector do we want to change?
            vecind = strmatch(statusvariable, statusvectortemplate);
            handles.status.guistatusvector(vecind) = value;
        end
        
        % in this case no update, just a call to update all elements
        for i = 1:length(guielements)
            % we substract the status vector with the respective definition
            % for each element. if -1 shows up, a requirement is not
            % fulfilled and we hide the corresponding UI element
            diff = handles.status.guistatusvector - guirequirements{i};
            if ismember(-1, diff)
                set(eval(guielements{i}), 'Enable', 'off');
            else
                set(eval(guielements{i}), 'Enable', 'on');
            end
        end
        
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
                fprintf(fid,'\t%s',handles.molecules(i).name);
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

       h = information_box('Clustersound','Yeah, Groovy!\nI''ll prepare the data for you...');
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
        % use only selected molecules
        listindices = getrealselectedmolecules();
        
        % show drift correction window and retrieve corrected values
        handles = driftcorrection(handles, listindices);
        
        % background correction
        handles.peakdata=subtractbg(handles.raw_peakdata,handles.bgcorrectiondata);
        
        % run calibration
        handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
        guidata(Parent,handles);
        
        gui_status_update('drift_corrected', 1);
        gui_status_update('calibrated', 1);
        gui_status_update('bg_corrected', 1);
        gui_status_update('changed', 1);
    end

    function labbookimport(hObject,~)
        [pathname,filename]=readfromlabbook();
        
        if ~strcmp(filename,'')
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
        % this function exports ASCII data of area and areaerror of selected cluster series to .txt file
        handles=guidata(hObject);

        searchstring=get(e_searchstring,'String');
        [handles.seriesarea,handles.seriesareaerror,serieslist]=sortmolecules(handles.molecules,searchstring,handles.peakdata);
        guidata(hObject,handles);
        
        % retrieve the name of the series to be exported
        seriesid = get(ListSeries, 'Value');
        seriesstring = get(ListSeries, 'String');
        seriesname = seriesstring(seriesid);
        
        % create one string out of the list seriesname (for use in filename)
        seriesname_string = '';
        for i=1:length(seriesid)
            seriesname_string = [seriesname_string '_' seriesname{i}];
        end
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) seriesname_string '.txt'];
        
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);
        handles=guidata(Parent);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            fid=fopen(fullfile(pathname,filename),'w');
            
            fprintf(fid,'\t');
            for i=seriesid
                fprintf(fid,'%s\t(error)\t',serieslist{i});
            end
            fprintf(fid,'\n');
            %size(handles.seriesarea,1)
            for i=1:size(handles.seriesarea,1)
                fprintf(fid,'%i\t',i-1);
                for j=seriesid
                    fprintf(fid,'%e\t%e\t',handles.seriesarea(i,j),handles.seriesareaerror(i,j));
                end
                fprintf(fid,'\n');
            end
        end
    end

    function listseriesclick(hObject,~)
        handles=guidata(hObject);

        ixlist=get(ListSeries,'Value');
        ix = ixlist(1);
                
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

    function menuloadmoleculesfolder(hObject,~)
        handles=guidata(Parent);
        folder=uigetdir();
        
        if length(folder)>1 %cancel returns folder=0
            handles.molecules=load_molecules_from_folder(folder,foldertolist(folder),handles.peakdata);
            guidata(Parent,handles);
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        gui_status_update('molecules_loaded', 1);
        gui_status_update('changed', 1);
    end

    function menuloadmoleculesifd(hObject,~)
        handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.ifd','IsotopeFit data file (*.ifd)'},...
            'Open IsotopeFit data file');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            data={}; %load needs a predefined variable
            load(fullfile(pathname,filename),'-mat');

            handles.molecules=convert_molecule_datatype(data.molecules);
                       
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        gui_status_update('molecules_loaded', 1);
        gui_status_update('changed', 1);
    end

    function menuloadmoleculesifm(hObject,~)
        handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.ifm','IsotopeFit molecules file (*.ifm)'},...
            'Open IsotopeFit molecules file');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            handles.molecules=load_molecules_from_ifm(fullfile(pathname,filename),handles.peakdata);
            
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end

        gui_status_update('molecules_loaded', 1);
        gui_status_update('changed', 1);
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
            
            handles.molecules=convert_molecule_datatype(data.molecules);
            
            %Calibration data
            handles.calibration=data.calibration;
            
            handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
            handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
            handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
            
            
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        gui_status_update('molecules_loaded', 1);
        gui_status_update('calibrated', 1);
        gui_status_update('changed', 1);
    end

    function menubgcorrection(hObject,~)
        handles=guidata(Parent);
        [handles.bgcorrectiondata, handles.startind, handles.endind]=bg_correction(handles.raw_peakdata,handles.bgcorrectiondata);    
        handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
        handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
        
        % run calibration again, because it is lost, when the background
        % correction is applied
        handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);

        guidata(Parent,handles);
        gui_status_update('bg_corrected', 1);
        gui_status_update('changed', 1);
    end

    function menucalibration(hObject,~)
        handles=guidata(Parent);
        
        peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
        peakdata=subtractbg(peakdata,handles.bgcorrectiondata);
        
        [handles.calibration,handles.molecules]= calibrate(peakdata,handles.molecules,handles.calibration,handles.settings);
            
        
        handles.peakdata=subtractmassoffset(peakdata,handles.calibration);
        guidata(Parent,handles);
        gui_status_update('calibrated', 1);
        gui_status_update('changed', 1);
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
        
        gui_status_update('file_loaded', 1);
        gui_status_update('calibrated', 0);
        gui_status_update('molecules_loaded', 0);
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
        
        gui_status_update('file_loaded', 1);
        gui_status_update('calibrated', 0);
        gui_status_update('molecules_loaded', 0);
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
        % to 3 (= any file) and determine later what it is
        else
            [pathname, filename, suffix] = fileparts(fullpath);
            filename = [filename, suffix];
            filterindex = 3;
        end
        
        % check if the user clicked on Cancel
        if (strcmp(class(filename),'double') && strcmp(class(pathname),'double'))
            return
        end
        
        % if the filterindex is 3, we do not know for sure which file was
        % chosen. hence we have to retrieve the actual filename suffix
        if filterindex == 3
            [~, ~, suffix] = fileparts(filename);
            if strcmp(suffix, '.ifd')
                filterindex = 1;
            elseif strcmp(suffix, '.h5')
                filterindex = 2;
            else % assume it's ASCII
                filterindex = 4;
            end
        end
        
        % before we load the file we clear all listboxes and plots
        clearall();

        handles=guidata(Parent);
        if ~(isequal(filename,0) || isequal(pathname,0))
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
                    
                    if ~isfield(handles.bgcorrectiondata,'bgm') %compatibility: old bg correction method
                        fprintf('Old File. Fixing background correction data...');
                        handles.bgcorrectiondata.bgm=[];
                        handles.bgcorrectiondata.bgy=[];
                        fprintf(' done\n');
                    end
                    
                    handles.molecules=convert_molecule_datatype(data.molecules);
                    
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
                    
                    gui_status_update('file_loaded', 1);
                    gui_status_update('calibrated', 1);
                    gui_status_update('molecules_loaded', 1);
                case 2 %h5
                    load_h5(pathname,filename);
                case 4 %ASCII
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

    function save_file(hObject, ~, method)
        handles=guidata(Parent);
        
        if (strcmp(method,'saveas')||strcmp(handles.fileinfo.filename,''))&&~strcmp(method,'autosave')
            [filename, pathname, ~] = uiputfile( ...
                {'*.ifd','IsotopeFit data file (*.ifd)'
                '*.*', 'All Files (*.*)'},...
                'Save as',[handles.fileinfo.pathname,handles.fileinfo.originalfilename,'.ifd']);
        elseif strcmp(method,'autosave')
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
            if ~strcmp(method,'autosave')
                handles.fileinfo.filename=filename;
                handles.fileinfo.pathname=pathname;
                
                % also belongs in here: if we didn't autosave, we want our
                % status to be "unchanged"
                gui_status_update('changed', 0);
            end
            
            guidata(Parent,handles);
         end
         
        %write filename to visible display:
        set(filenamedisplay, 'String', handles.fileinfo.filename)
    end



    function moleculelistclick(hObject,~)
        handles=guidata(Parent);
        
        index = getrealselectedmolecules();
        
        % we can always only plot one molecule. if several have been
        % selected we just plot the first one
        if (length(index) >= 2)
            index = index(1);
        end
        
        % plot the molecule
        plotmolecule(index);
        
        % set the displays
        % note this is not the nominal mass
        set(comdisplay, 'String', num2str(handles.molecules(index).com));
        set(areadisplay, 'String', num2str(handles.molecules(index).area));
        res = resolutionbycalibration(handles.calibration,handles.molecules(index).com);
        set(resolutiondisplay, 'String', num2str(res));
    end

    function filterListMolecules(~,~)
        handles=guidata(Parent);
        
        % Get text currently in molecule listbox
        listboxText = get(ListMolecules,'string');
        
        % get text to be used as a filter
        filtertext = get(ListFilter,'string');
        
        % check if our filtertext is empty
        if ~isempty(filtertext)
            
            set(ListMolecules, 'Value', 1);

            % filter
            cellArrayOfMatches = regexpi(listboxText,['(.*' filtertext '.*)']);
            arrayOfMatches = cellfun(@(x) ~isempty(x), cellArrayOfMatches);

            % create new listbox text
            newListMoleculesText = listboxText(arrayOfMatches);
            set(ListMolecules,'string', newListMoleculesText);
            
            handles.status.moleculesfiltered = 1;
        else
            % it's empty. we just fill the Listbox with all molecules
            
            % first read out, what is currently selected
            curr_ind = getrealselectedmolecules();
            
            % fill in new (all) values
            molecules2listbox(ListMolecules, handles.molecules);
            
            % select the previously selected molecule
            set(ListMolecules, 'Value', curr_ind);

            handles.status.moleculesfiltered = 0;
        end
        
        guidata(Parent,handles);
    end

    function finalindex = getrealselectedmolecules()
        % this function retrieves the real molecule ids, even if there is
        % currently only a subset in the listbox displayed (filtered)
        
        handles=guidata(Parent);
        
        % retrieve indices
        index=get(ListMolecules,'Value');
        
        if handles.status.moleculesfiltered == 1
            % this is computationally expensive. we only do this if
            % necessary
            
            % create a list of selected names
            listboxText = get(ListMolecules,'string');
            molnames = listboxText(index);

            finalindex = [];
                        
            molnamelist = {handles.molecules.name};

            % walk through molecule list
            for i = 1:length(molnamelist)
                % ... and check if any of the names match
                if any(strcmp(molnamelist{i}, molnames))
                    finalindex = [finalindex, i];
                end
            end
        else
            % not filtered.
            finalindex = index;
        end
    end

    function plotmolecule(index)
        handles=guidata(Parent);
        
        % find min and max index of mass range that should be plotted i.e.
        % certain range (30 sigma) around the selected molecules
        ind = findmassrange(handles.peakdata(:,1)',handles.molecules(index),resolutionbycalibration(handles.calibration,handles.molecules(index).com),0,30);
        
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
        %[~,i]=max(handles.molecules(index).peakdata(:,2));
 %       calcmassaxis
        xlim(dataaxes,[calcmassaxis(1),calcmassaxis(end)]);  
        %ylim(previewaxes,[0,max(max(handles.molecules(index).peakdata(:,2)),max(handles.peakdata(handles.molecules(index).minind:handles.molecules(index).maxind,2)))]);

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
            name=[molecules(i).name '['];
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
%           npins=mass2ind(peakdata(:,1)',molecules(i).maxmass)-mass2ind(peakdata(:,1)',molecules(i).minmass); %number of pins
%           b=(molecules(i).maxmass-molecules(i).minmass)/npins; %mean pin-distance
           
%           dividion by sqrt(m):
            b=sqrt(molecules(i).com);
     
            areaout(lineix,rowix)=molecules(i).area/b;
            areaerrorout(lineix,rowix)=molecules(i).areaerror/b;
        end
        for i=1:length(attached)
            sortlist{i}=[searchstring 'n' attached{i}(1:end-1)];
        end
    end

    function fitbuttonclick(hObject,eventdata)
        handles=guidata(hObject);
        
        % indices for all molecules selected
        index=getrealselectedmolecules();
        
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
        
        gui_status_update('changed', 1);
        
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

    function closeandsave(~, ~)
        % get settings
        handles = guidata(Parent);
        
        % is a file loaded?
        if handles.status.guistatusvector(1) == 1
            % has it changed?
            if handles.status.guistatusvector(6) == 1
                result = questdlg('It seems the file has changed. Do you want to save it?', 'Save file?');
                switch result
                    case 'Yes'
                        save_file(Parent,'','save');
                    case 'Cancel'
                        return
                    case 'No'
                        ;
                end
            end
        end
        
        % finally close
        delete(Parent)
    end
end