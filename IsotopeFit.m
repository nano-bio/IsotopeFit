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
dataaxes = dataviewer(Parent, 'dataaxes', gridpos(64,64,33,62,1,54,0.025,0.01), 50, 29, true, @dataaxesclick);

% Area Axes

areaaxes = dataviewer(Parent, 'areaaxes', gridpos(64,64,1,32,10,54,0.025,0.03), 50, 29, false, @areaaxesclick);
         
% ===== TOOLBAR LEFT OF AREA AXES ===== %

e_searchstring=uicontrol(Parent,'Style','edit',...
    'Tag','e_searchstring',...
    'Units','normalized',...
    'String','N/A',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(64,64,30,32,1,7,0.01,0.01));         
         
b_sortlist = uicontrol(Parent,'style','pushbutton',...
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
    'Position',gridpos(64,64,15,62,53,64,0.01,0.01));

ListFilter = uicontrol(Parent,'Style','edit',...
    'String','',...
    'Units','normalized',...
    'Callback',@filterListMolecules,...
    'Position',gridpos(64,64,13,15,53,61,0.01,0.01));

b_listfilter = uicontrol(Parent,'style','pushbutton',...
    'string','Filter',...
    'Callback',@filterListMolecules,...
    'Units','normalized',...
    'Position',gridpos(64,64,13,15,61,64,0.01,0.01));

b_removemolec = uicontrol(Parent,'style','pushbutton',...
    'string','Remove selected molecules',...
    'Callback',@remove_molecules,...
    'Units','normalized',...
    'Position',gridpos(64,64,10,13,53,64,0.01,0.01));
      
% display for the mass of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Center of mass:',...
    'Units','normalized',...
    'Position',gridpos(64,64,8,10,53,58,0.01,0.01));

comdisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,8,10,58,64,0.01,0.01));

% display for the resolution of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Resolution:',...
    'Units','normalized',...
    'Position',gridpos(64,64,6,8,53,58,0.01,0.01));

resolutiondisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,6,8,58,64,0.01,0.01));

% display for the area of the current molecule

uicontrol(Parent,'Style','Text',...
    'String','Area:',...
    'Units','normalized',...
    'Position',gridpos(64,64,4,6,53,58,0.01,0.01));

areadisplay = uicontrol(Parent,'Style','Text',...
    'String','',...
    'Units','normalized',...
    'Position',gridpos(64,64,4,6,58,64,0.01,0.01));

% Now for the fit button:

b_fit = uicontrol(Parent,'style','pushbutton',...
          'string','Fit',...
          'Callback',@fitbuttonclick,...
          'Units','normalized',...
          'Position',gridpos(64,64,1,4,53,57,0.01,0.01));
      
% Listbox for the fit method
      
ListMethod = uicontrol(Parent,'style','popupmenu',...
          'string',{'Ranges','Molecules'},...
          'Units','normalized',...
          'Position',gridpos(64,64,1,4,60,64,0.01,0.01));
      
% Listbox for the fit range
      
ListRange = uicontrol(Parent,'style','popupmenu',...
          'string',{'Selected', 'All', 'View'},...
          'Units','normalized',...
          'Position',gridpos(64,64,1,4,57,60,0.01,0.01));
      

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
    'Position',gridpos(64,64,62,64,8,30,0.01,0.01));

% This copies the filename to the clipboard (for searching in the
% labbook etc.

uicontrol(Parent,'style','pushbutton',...
          'string','Copy',...
          'Callback',@copyfntoclipboard,...
          'Units','normalized',...
          'TooltipString','Click to copy the filename to the clipboard',...
          'Position',gridpos(64,64,62,64,31,34,0.01,0.01));
      

% Button to refresh plot window
b_refresh = uicontrol(Parent,'style','pushbutton',...
          'string','Refresh View',...
          'Callback',@(s,e) plotmolecule(0),...
          'Units','normalized',...
          'Position',gridpos(64,64,62,64,48,53,0.01,0.01));

% button to mark molecules in current view
b_markmoleculesinview = uicontrol(Parent,'style','pushbutton',...
          'string','Mark Molecules',...
          'Callback',@markmoleculesinview,...
          'Units','normalized',...
          'Position',gridpos(64,64,62,64,43,48,0.01,0.01));
      
% Plot overview
      
b_ov = uicontrol(Parent,'style','pushbutton',...
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
       
mmolecules = uimenu('Label','Molecules','Enable','on');
       mloadfromfolder = uimenu(mmolecules,'Label','Load from folder...','Callback',@menuloadmoleculesfolder);
       mloadfromif = uimenu(mmolecules,'Label','Load from IsotopeFit file...','Callback',@menuloadmoleculesif);
       mgenerateifm = uimenu(mmolecules,'Label','Generate ifm file...','Callback',@menugenerateifm,'Separator','on');
       
mcal = uimenu('Label','Calibration');
       mcalbgc=uimenu(mcal,'Label','Background correction...','Callback',@menubgcorrection,'Enable','off');
       mcalcal=uimenu(mcal,'Label','Mass- and resolution calibration...','Callback',@menucalibration,'Enable','off');
       mpeakshape=uimenu(mcal,'Label','Edit peak shape...','Callback',@menupeakshape,'Enable','on','Separator','on');
       mpd2raw=uimenu(mcal,'Label','Write peakdata to raw peakdata...','Callback',@menupeakdata2raw,'Enable','on');
       mpdsmoothmass=uimenu(mcal,'Label','Smooth massaxis...','Callback',@menusmoothmassaxis,'Enable','on');
       mloadcal=uimenu(mcal,'Label','Load calibration and molecules from ifd...','Callback',@menuloadcalibration,'Enable','on','Separator','on');
       mcaldc=uimenu(mcal,'Label','Drift correction...','Callback',@menudc,'Enable','on');
       mcalsave=uimenu(mcal,'Label','Save Calibration to File...','Callback',@menusavecal,'Enable','on', 'Separator', 'on');
       
mdata = uimenu('Label','Data');
       mexport = uimenu(mdata,'Label','Export','Enable','on');
               mdatacs = uimenu(mexport,'Label','Cluster Series...','Callback',@menuexportdataclick,'Enable','on');
               mdatacv = uimenu(mexport,'Label','Current View...','Callback',@menuexportcurrentview,'Enable','on');
               mdatacms = uimenu(mexport,'Label','Calibrated Mass Spectrum...','Callback',@menuexportmassspec,'Enable','on');
               mdatasmooth = uimenu(mexport,'Label','Smooth Mass Spectrum...','Callback',@menuexportsmoothmassspec,'Enable','on');
               mdatafms = uimenu(mexport,'Label','Fitted Mass Spectrum...','Callback',@menuexportfittedspec,'Enable','on');
               mdatafms = uimenu(mexport,'Label','Cal. Mass Spectrum for Selected Series...','Callback',@export_series_spec,'Enable','on');
               mdataes = uimenu(mexport,'Label','Energy scan','Enable','on','Separator', 'on');
                    mdataes_all = uimenu(mdataes,'Label','All molecules','Callback',@export_energy_scan,'Enable','on');
                    mdataes_sel = uimenu(mdataes,'Label','Selected molecules','Callback',@export_energy_scan,'Enable','on');
                    
       mconvcore = uimenu(mdata,'Label','Show convolution core (experimental!)','Enable','on');
               mconvcore_cv=uimenu(mconvcore,'Label','Current view...','Callback',@menuconvcore,'Enable','on');
               mconvcore_map=uimenu(mconvcore,'Label','Map...','Callback',@menuconvcoremap,'Enable','on');
       mautodetect = uimenu(mdata,'Label','Autodetect Peaks...','Callback',@showlargedeviations,'Enable','on');
       mratio = uimenu(mdata,'Label','Calculate ratio of 2 compounds...','Enable','on','Callback',@menuratio);
       mplay = uimenu(mdata,'Label','Play','Separator','on');
               mplayorig = uimenu(mplay,'Label','Original','Callback',@menuplay,'Enable','on');
               mplayfit = uimenu(mplay,'Label','Fitted Data','Callback',@menuplay,'Enable','on');
       merrors = uimenu(mdata,'Label','Errors and Noise','Separator','on');
               uimenu(merrors,'Label','Noise analysis','Callback',@menunoiseanalysis,'Enable','on');
               uimenu(merrors,'Label','Error analysis','Callback',@menuerroranalysis,'Enable','on');
               %uimenu(mdata,'Label','All Errors','Separator','on','Callback',@geterrors,'Enable','on');
       
%%       
% ===== END OF LAYOUT ===== %     
addpath(genpath('EXTERNAL FUNCTIONS'));
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
        
        % Variables for Cluster series
        handles.seriesarea = [];
        handles.seriesareaerror = [];
        handles.seriesindex = [];
        
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
        
        handles.status.guistatusvector = [0 0 0 0 0 0 0 0];
        
        handles.status.rootindexchanged = 0;
        
        %initial calibration data
        handles.calibration=standardcalibration();
        
        guidata(Parent,handles);
        
        handles = gui_status_update();
        
        %empty area listbox and reset statusvariable
        handles = gui_status_update('cs_selected', 0, handles);
        set(ListSeries,'Value',1);
        set(ListSeries,'String','');
        
        %clear axes
        cla(areaaxes.axes);
        cla(dataaxes.axes);
    end

    function menuratio(hObject,~)
        handles=guidata(Parent);
        
        %input dialog
        prompt = {'First compound:','Second compound:','Upper mass limit:','Parent (optional):'};
        dlg_title = 'Ratio of compounds';
        num_lines = 1;
        def = {'','','inf',''};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        
        comp1=['[' answer{1} ']'];
        comp2=['[' answer{2} ']'];
        if strcmp(answer{3},'inf')
            max_mass=handles.peakdata(end,1);
        else
            max_mass=str2double(answer{3});
        end
        
        F1=0; %fraction of compound 1
        F2=0; %fraction of compound 2
        
        h=waitbar(0,'Busy...');
        for i=1:length(handles.molecules)
            % in case a parent molecule is chosen, only use molecules that
            % include parent for calculation
            if ~isempty(strfind(handles.molecules(i).name,answer{4})) || isempty(answer{4})
                %find positions of comp1 and comp2 in molecule name
                molname=[handles.molecules(i).name,'['];
                a1=get_number_in_molname(molname,comp1);
                a2=get_number_in_molname(molname,comp2);
            
                % scruffy solution to calculate O2 ratio when only O is in
                % spectrum (can only be used in special cases; line above
                % needs to be commented)
%                 if strcmp(answer{2},'O2')
%                     comp2 = '[O]';
%                     a2_temp=get_number_in_molname(molname,comp2);
%                     a2=floor(a2_temp/2);
%                 else
%                     a2=get_number_in_molname(molname,comp2);
%                 end
% 
                % try to generalize solution:  
%                 if strcmp(answer{2}(end-1:end),'2') && isempty(a2) 
%                     comp2 = answer{2}(1:end-1);
%                     a2_temp = get_number_in_molname(molname,comp2);
%                     a2=floor(a2_temp/2);
%                 else
%                     a2=get_number_in_molname(molname,comp2);
%                 end
%             

                if a1+a2>0
                    F1=F1+handles.molecules(i).area/sqrt(handles.molecules(i).com)*a1/(a1+a2);
                    F2=F2+handles.molecules(i).area/sqrt(handles.molecules(i).com)*a2/(a1+a2);
                end
                waitbar(handles.molecules(i).maxmass/max_mass);
                
                if handles.molecules(i).maxmass>max_mass %then terminate execution
                    break
                end
            end
        end
        close(h);
        %msgbox(sprintf('%s: %f\n%s: %f\n%s/%s: %f',comp1,F1,comp2,F2,comp1,comp2,F1/F2),'Ratio');
        msgbox(sprintf('%s: %f\n%s: %f\n%s/%s: %f',comp1,F1,['[' answer{2} ']'],F2,comp1,['[' answer{2} ']'],F1/F2),'Ratio');
    end

    function out=get_number_in_molname(molname,comp)
        % finds clusternumber n in a given molecule name
        % i.e. molname=[C60][CO2]5
        %      comp=[CO2]
        % ==>  out=5
        
        pos=strfind(molname,comp);
        
        if ~isempty(pos)
            k=pos(1)+length(comp);
            temp='';
            while molname(k)~='[';
                temp=[temp,molname(k)];
                k=k+1;
            end
            if isempty(temp)
                out=1;
            else
                out=str2double(temp);
            end
        else
            out=0;
        end
    end

    function markmoleculesinview(~,~)
        % this function marks all molecules in the currently viewed
        % massrange and marks them in the list.
        handles=guidata(Parent);
        limits= get(dataaxes.axes, 'XLim');
        % those are the molecules in the range
        moleculelist=molecules_in_massrange(handles.molecules,limits(1),limits(2));
        
        % in case the list is filtered we need to remove that - filtered
        % molecules could be in our range
        if handles.status.moleculesfiltered == 1
            set(ListFilter,'string', '');
            filterListMolecules;
        end
        
        % select them
        set(ListMolecules,'Value', moleculelist);
        % refresh view for the nicer looks!
        plotmolecule(0);
    end
        
    function menuconvcore(hObject,~)
        handles=guidata(Parent);
        limits= get(dataaxes.axes, 'XLim');
            
        %find molecules that are in current view
        moleculelist=molecules_in_massrange_with_sigma(handles.molecules,limits(1),limits(2),handles.calibration,handles.settings.searchrange);
        
        minind=mass2ind(handles.peakdata(:,1)',limits(1));
        maxind=mass2ind(handles.peakdata(:,1)',limits(2));
                        
        show_convolution_core(handles.peakdata(minind:maxind,:),handles.molecules(moleculelist));
        
        guidata(Parent,handles);
    end

    function menuconvcoremap(hObject,~)
        handles=guidata(Parent);
        
        show_convolution_core_map(handles.peakdata,handles.molecules);
        
        guidata(Parent,handles);
    end

    function handles = gui_status_update(statusvariable, value, handles)
        % This function updates the availability of GUI elements according
        % certain states of the evaluation. E.g. a mass spec can only be
        % calibrated if molecules have been loaded. It either takes no
        % argument and then updates all GUI elements according to the
        % status vector handles.status.guistatusvector or it takes 3
        % arguments:
        % statusvariable -> state to be changed
        % value -> value (0|1) for the given state
        % handles -> handles structure to be changed
        % for a list of possible statusvariables, see the variable 
        % statusvectortemplate
        
        % ============== IMPORTANT COMMENT ===============
        % When you add fields to statusvector, dont forget to change the
        % length of guistatusvector initialization in init() and
        % open_file() functions!!
        % ========== END OF IMPORTANT COMMENT ============
        
        % possible status elements
        statusvectortemplate = {'file_loaded',...
            'molecules_loaded',...
            'calibrated',...
            'bg_corrected',...
            'drift_corrected',...
            'changed',...
            'fitted',...
            'cs_selected'};
        
        % list of gui elements that should be hidden/shown
        guielements = {'mcalbgc', 'mcalcal', 'mloadcal', 'mcaldc', 'mpd2raw', 'mloadfromfolder', 'mloadfromif','mgenerateifm', 'mcal', 'mcalsave', 'msave', 'msaveas',...
                       'mplay', 'mplayfit', 'mdata', 'mdatacs', 'mdatacms', 'mdatafms','mconvcore','mratio', 'merrors', 'b_sortlist',...
                       'b_refresh','mpeakshape','b_markmoleculesinview', 'b_listfilter', 'b_removemolec', 'b_fit', 'ListMolecules',...
                       'mautodetect', 'ListSeries', 'b_ov', 'e_searchstring', 'ListFilter'};
        % according requirement list. each entry in each vector corresponds
        % to one of the states defined above
        guirequirements = {[1 0 0 0 0 0 0 0],...   % mcalbgc
                           [1 1 0 0 0 0 0 0],...   % mcalcal
                           [1 0 0 0 0 0 0 0],...   % mloadcal
                           [1 1 1 0 0 0 0 0],...   % mcaldc
                           [1 1 1 0 0 0 0 0],...   % mpd2raw
                           [1 0 0 0 0 0 0 0],...   % mloadfromfolder
                           [1 0 0 0 0 0 0 0],...   % mloadfromif
                           [0 0 0 0 0 0 0 0],...   % mgenerateifm
                           [1 0 0 0 0 0 0 0],...   % mcal
                           [1 1 1 0 0 0 0 0],...   % mcalsave
                           [1 0 0 0 0 0 0 0],...   % msave
                           [1 0 0 0 0 0 0 0],...   % msaveas
                           [1 0 0 0 0 0 0 0],...   % mplay
                           [1 1 1 0 0 0 1 0],...   % mplayfit
                           [1 0 0 0 0 0 0 0],...   % mdata
                           [1 1 1 0 0 0 1 1],...   % mdatacs
                           [1 1 1 0 0 0 0 0],...   % mdatacms
                           [1 1 1 0 0 0 1 0],...   % mdatafms
                           [1 1 1 0 0 0 1 0],...   % mconvcore
                           [1 1 1 0 0 0 1 0],...   % mratio
                           [1 1 1 0 0 0 0 0],...   % merrors
                           [1 1 1 0 0 0 1 0],...   % b_sortlist
                           [1 1 1 0 0 0 0 0],...   % b_refresh
                           [1 1 0 0 0 0 0 0],...   % mpeakshape  
                           [1 1 1 0 0 0 0 0],...   % b_markmoleculesinview
                           [1 1 0 0 0 0 0 0],...   % b_listfilter
                           [1 1 0 0 0 0 0 0],...   % b_removemolec 
                           [1 1 0 0 0 0 0 0],...   % b_fit
                           [1 1 0 0 0 0 0 0],...   % ListMolecules
                           [1 0 0 0 0 0 0 0],...   % mautodetect
                           [1 1 0 0 0 0 0 0],...   % ListSeries
                           [1 0 0 0 0 0 0 0],...   % b_ov
                           [1 1 0 0 0 0 0 0],...   % e_searchstring
                           [1 1 0 0 0 0 0 0]};     % ListFilter
        
        if nargin > 1
            % we want to update the status vector
            
            % which element in the vector do we want to change?
            vecind = strmatch(statusvariable, statusvectortemplate);
            handles.status.guistatusvector(vecind) = value;
        else
            % load handles structure from parent
            handles = guidata(Parent);
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

    function menuexportsmoothmassspec(hObject,~)
        %% Exports Peakdata of entire mass range to ascii file
        handles=guidata(hObject);
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_smooth_spec.txt'];
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export Smooth Mass Spectrum',...
            filenamesuggestion);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            % handles=guidata(hObject);
            
            
%             %apply gaussian smoothing by pointwise cross correlation with a
%             %gaussian peak (resolution dependent)
%             smooth_data=zeros(size(handles.peakdata(:,1)));
%             tic
%             sigma=sigmabycalibration(handles.calibration,handles.peakdata(:,1));
%             for i=1:length(smooth_data)
%                 if mod(i,1000)==0
%                     i/length(smooth_data)
%                 end
%                 current_mass=handles.peakdata(i,1);
%                 minind=mass2ind(handles.peakdata(:,1)',current_mass-3*sigma(i));
%                 maxind=mass2ind(handles.peakdata(:,1)',current_mass+3*sigma(i));
%                 smooth_data(i)=sum(handles.peakdata(minind:maxind,2).*normpdf(handles.peakdata(minind:maxind,1),current_mass,sigma(i)/2));
%             end
%             toc
            
            %           smoothing via fourier transform
            %shiftsearch=(handles.peakdata(:,1)-(handles.peakdata(1,1)+handles.peakdata(end,1))/2);
            
            %input dialog
            prompt = {'Sigma (Time bins):'};
            dlg_title = 'Gaussian Smoothing';
            num_lines = 1;
            def = {'5'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);

            shiftsearch=[0:(size(handles.peakdata,1)-1)]-size(handles.peakdata,1)/2;
            
            gausspeak=normpdf(shiftsearch,0,str2double(answer{1}));
            
            %    data=10*getdata(werte,peaks,height,0);
            %    data2=10*getdata(werte,peaks,height,shift);
             
            smooth_data=ifftshift(ifft(fft(handles.peakdata(end:-1:1,2)).*fft(gausspeak')));
            smooth_data=smooth_data(end:-1:1);
            dataaxes.cplot(handles.peakdata(:,1),handles.peakdata(:,2),'color',[0.7,0.7,0.7]);
            dataaxes.cplot(handles.peakdata(:,1),smooth_data,'k-');
            
            %write title line
            fid=fopen(fullfile(pathname,filename),'w');
            fprintf(fid,'Mass (Dalton)\tSignal (a.u.)\n');
            fclose(fid);
                      
            %append data
            fprintf('dlmwrite. please wait...');
            dlmwrite(fullfile(pathname,filename),[handles.peakdata(:,1),smooth_data],'-append','delimiter','\t','precision','%e');
            fprintf(' done.\n');
        end
    end

    function menuexportmassspec(hObject,~)
        %% Exports Peakdata of entire mass range to ascii file
        handles=guidata(hObject);
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_calib_spec.txt'];
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export Mass Spectrum',...
            filenamesuggestion);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            % handles=guidata(hObject);
           
            %write title line
            fid=fopen(fullfile(pathname,filename),'w');
            fprintf(fid,'Mass (Dalton)\tSignal (a.u.)\n');
            fclose(fid);

            %append data
            dlmwrite(fullfile(pathname,filename),handles.peakdata,'-append','delimiter','\t','precision','%e');
        end
    end

    function menuexportfittedspec(hObject,~)
        %% Exorts fitted spectrum of entire mass range to ascii file
        handles=guidata(hObject);
        %startpathname = handles.fileinfo.pathname;
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_fitted_spec.txt'];
        
        [filename, pathname] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            resolutionaxis=resolutionbycalibration(handles.calibration,handles.peakdata(:,1)');
            % calculate fitted spectrum for all molecules
            fitted_data=multispec(handles.molecules,resolutionaxis,0,handles.peakdata(:,1)',handles.calibration.shape)';
        
            % write data to ascii file
            fid=fopen(fullfile(pathname,filename),'w');
            % column designations
            fprintf(fid,'Massaxis\tFitted Signal\n');
            fclose(fid);
            
            % append data matrix to ascii file
            dlmwrite(fullfile(pathname,filename),[handles.peakdata(:,1),fitted_data],'-append','delimiter','\t','precision','%e');
        end
    end

    function menuexportcurrentview(hObject,~)
        %% Exports Peakdata + fitted curves of current plot to ascii file
        handles = guidata(hObject);
        limits = get(dataaxes.axes, 'XLim');
        lowmass = num2str(round(limits(1)));
        highmass = num2str(round(limits(2)));
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_mass_' lowmass '_' highmass '.txt'];
                     
        if handles.status.guistatusvector(2) == 0
            choice = questdlg('There are no molecules loaded yet! Do you want to export current view of spectrum anyway?',...
                'Warning!', 'Yes', 'No', 'No');
        elseif handles.status.guistatusvector(3) == 0
            choice = questdlg('Spectrum is not calibrated! Do you want to export current view of spectrum anyway?',...
                'Warning!', 'Yes', 'No', 'No');
        elseif handles.status.guistatusvector(7) == 0
            choice = questdlg('Molecules are not fitted! Do you want to export current view of spectrum anyway?',...
                'Warning!', 'Yes', 'No', 'No');
        else
            choice = 'Yes';
        end
        
        if strcmp(choice, 'No')
           return; 
        end
            
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);

        
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            fid=fopen(fullfile(pathname,filename),'w');
            
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
            for i=moleculelist'
                %calculate fitted data for every molecule:
                fitted_data(:,k)=multispec(handles.molecules(i),resolutionaxis,0,massaxis,handles.calibration.shape)';
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

    function menuerroranalysis(hObject, eventdata)
        handles=guidata(hObject);
        
        moleculeindex=getrealselectedmolecules();
        moleculeindex=moleculeindex(1);
        
        involved=molecules_in_massrange_with_sigma(handles.molecules,handles.molecules(moleculeindex).minmass,handles.molecules(moleculeindex).maxmass,handles.calibration,handles.settings.searchrange);
        
        massind=findmassrange2(handles.peakdata(:,1),handles.molecules(involved),resolutionbycalibration(handles.calibration,handles.molecules(moleculeindex).com),0,handles.settings.searchrange*3);
        
        massaxis=handles.peakdata(massind,1)';
        spec_measured=handles.peakdata(massind,2)';
               
        searchrange=0.01;
        testareas=handles.molecules(moleculeindex).area+(linspace(-searchrange,searchrange,20)*(1+handles.molecules(moleculeindex).area/10));
        testmsd=zeros(size(testareas));
        
        handles.molecules(involved).name
        
        for i=1:length(testareas)
            [testmsd(i),spec]=msd_area_variation(spec_measured,massaxis,handles.molecules(setdiff(involved,moleculeindex)),handles.molecules(moleculeindex),testareas(i),handles.calibration);
            %plot(massaxis,multispecparameters(massaxis,handles.molecules(moleculeindex),[testareas(i),resolutionbycalibration(handles.calibration,handles.molecules(moleculeindex).com),0]),massaxis,spec);
            %drawnow
            fprintf('%i/%i\tMSD: %f\tArea: %f\n ',i,length(testareas),testmsd(i),testareas(i));
        end
                
        calcspec=multispec(handles.molecules(involved),resolutionbycalibration(handles.calibration,massaxis),0,massaxis,handles.calibration.shape);
        
        stdabw=sqrt(sum((calcspec-spec_measured).^2));
                
%        error=get_fitting_error2(spec_measured,massaxis,handles.molecules(moleculeindex),handles.molecules(setdiff(involved,moleculeindex)),handles.calibration);
        
        [minmsd,minind]=min(testmsd);
                
        areainterp=testareas(1):(testareas(minind)-testareas(1))/1000:testareas(minind);
        testmsdinterp=spline(testareas,testmsd,areainterp);
        
        [~,ind]=min(abs(testmsdinterp-minmsd*1.0005));
        leftarea=areainterp(ind);
        
        areainterp=testareas(minind):(testareas(end)-testareas(minind))/1000:testareas(end);
        testmsdinterp=spline(testareas,testmsd,areainterp);
        
        [~,ind]=min(abs(testmsdinterp-minmsd*1.0005));
        rightarea=areainterp(ind);
        
        fprintf('Lower error: %f\n',leftarea);
        fprintf('Upper error: %f\n',rightarea);
        
        cla(areaaxes.axes)
        areaaxes.cplot(testareas,testmsd,testareas,repmat(minmsd*1.0005,1,length(testareas)))
        
%         
%         hold(areaaxes,'on');
% %        plot(areaaxes,testareas,repmat(errlevel_low,size(testareas)),testareas,repmat(errlevel_high,size(testareas)))
%         plot(areaaxes,testarea,testmsd,'ro');
%         ind=round(length(testareas)/2);
%         plot(areaaxes,testareas(1:ind),sqrt((testareas(1:ind)-testarea(2)).^2*s1+testmsd(2)^2),'r-');
%         plot(areaaxes,testareas(ind:end),sqrt((testareas(ind:end)-testarea(2)).^2*s2+testmsd(2)^2),'r-');
%         hold(areaaxes,'off');
%         
%         fprintf('\n 2nd Order Polynom Approximation: \n\n')
%         fprintf('Lower error: %f\n',testarea(2)-(0.1*testmsd(2))/sqrt(s1));
%         fprintf('Upper error: %f\n',testarea(2)+(0.1*testmsd(2))/sqrt(s2));
%         
%         
         [~,speclow]=msd_area_variation(spec_measured,massaxis,handles.molecules(setdiff(involved,moleculeindex)),handles.molecules(moleculeindex),leftarea,handles.calibration);
         [~,spechigh]=msd_area_variation(spec_measured,massaxis,handles.molecules(setdiff(involved,moleculeindex)),handles.molecules(moleculeindex),rightarea,handles.calibration);
%         
         dataaxes.cplot(massaxis,speclow,'b--');
         dataaxes.cplot(massaxis,spechigh,'g--');
        
        guidata(Parent,handles);
    end

    function menunoiseanalysis(hObject, eventdata)
        % adds noise to (generated) data and recalculates areas
        % saves evaluation for every noise-level to file
        % used for noise analysis/evaluation quality rating
        handles=guidata(hObject);
        
        %input dialog
        prompt = {'log(min Area):','log(max Area):','Number of Evaluations:','Filename:'};
        dlg_title = 'Noise Analysis';
        num_lines = 1;
        def = {'1','3','1000','noise_analysis.txt'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        
        nmin=str2double(answer{1});
        nmax=str2double(answer{2});
        
        nsteps=str2double(answer{3});
        
        fname=answer{4};
        
        deltar=handles.settings.deltaresolution/100;
        deltam=handles.settings.deltamass;
                       
        for i=1:nsteps
            % add noise
            fprintf('Step %i/%i\n',i,nsteps);
                        
            noisy_peakdata=handles.peakdata;
            noisy_peakdata(:,2)=poissrnd(handles.peakdata(:,2)*10^((nmax-nmin)/(nsteps-1)*(i-1)+nmin));
            
            molecules_temp=fitwithcalibration(handles.molecules,noisy_peakdata,handles.calibration,get(ListMethod,'Value'),handles.settings.searchrange,deltam,deltar,handles.settings.fittingmethod_main);
                
            out_data(i,1)=10^((nmax-nmin)/(nsteps-1)*(i-1)+nmin); %noise level
            for j=1:length(molecules_temp);
                out_data(i,j*2)=molecules_temp(j).area/out_data(i,1);
                out_data(i,j*2+1)=molecules_temp(j).areaerror/out_data(i,1);
            end
        end
        
        dlmwrite(fname,out_data,'delimiter','\t','precision','%e');
        fprintf('Data written to %s\n',fname);
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
               spec=multispec(handles.molecules,3000,0,t,handles.calibration.shape);
       end

       spec=smooth(spec,10);

       spec=log(spec-min(spec)+0.1);       
       spec=spec-mean(spec);

       spec=spec/max(abs(spec));
       dspec=diff(spec);
       dspec=dspec/max(abs(dspec));


       dataaxes.cplot(t,spec);

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
        
        handles = gui_status_update('drift_corrected', 1, handles);
        handles = gui_status_update('calibrated', 1, handles);
        handles = gui_status_update('bg_corrected', 1, handles);
        handles = gui_status_update('fitted', 0, handles);
        handles = gui_status_update('changed', 1, handles);
    end

    function labbookimport(hObject,~)
        
        % before importing new file, check if another file is loaded and if 
        % other file was changed. If yes -> ask "Save file?"
        answer = asksave();
        if strcmp(answer,'Close')
            return
        end
        
        [pathname,filename]=readfromlabbook();
        if ~strcmp(filename,'')
            load_h5(pathname,filename);
            handles=guidata(Parent);
            dataaxes.cplot(handles.peakdata(:,1),handles.peakdata(:,2));
            
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
        if exist(fullpath, 'file') == 2
            open_file(hObject, eventdata, fullpath);
        else % nope
            msgbox('No backup file found.');
        end
    end
    
    function menuexportdataclick(hObject,~)
        % this function exports ASCII data of area and areaerror of selected cluster series to .txt file
        handles=guidata(hObject);

        searchstring=get(e_searchstring,'String');
        [handles.seriesarea,handles.seriesareaerror,handles.seriesindex,serieslist]=sortmolecules(handles.molecules,searchstring,handles.peakdata);
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
                    if ~isnan(handles.seriesarea(i,j))
                        fprintf(fid,'%e\t%e\t',full(handles.seriesarea(i,j)),full(handles.seriesareaerror(i,j)));
                    else
                        fprintf(fid,'--\t--\t');
                    end
                end
                fprintf(fid,'\n');
            end
        end
    end





function menusavecal(hObject,~)
        % this function exports the calibration points to an ASCII file
        handles=guidata(hObject);

        % get data points for massoffset from mass calibration
        comlist = handles.calibration.comlist;
        massoffsetlist = handles.calibration.massoffsetlist;
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_massoffset_data.txt'];
        
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);
        handles=guidata(Parent);
        
        %write title line
        fid=fopen(fullfile(pathname,filename),'w');
        fprintf(fid,'Center of Mass(Dalton) \t Mass Offset (Dalton)\n');
        fclose(fid);
        
        %append data
        if ~(isequal(filename,0) || isequal(pathname,0))
            
            dlmwrite(fullfile(pathname, filename), [comlist, massoffsetlist], '-append', 'Delimiter', '\t', 'Precision', '%e');
                        
        end
    end

    function listseriesclick(hObject,~)
        handles=guidata(hObject);

        ixlist=get(ListSeries,'Value');
        ix = ixlist(1);
                
        j=1;
        for i=1:size(handles.seriesarea,1)
            if ~isnan(handles.seriesarea(i,ix))
                n(j)=i-1;
                data(j)=handles.seriesarea(i,ix);
                dataerror(j)=handles.seriesareaerror(i,ix);
                j=j+1;
            end
        end
        
        
        %area(areaaxes,n,data+dataerror,data-dataerror,'Facecolor',[0.7,0.7,0.7],'Linestyle','none');
        %hold off;
        cla(areaaxes.axes)
        areaaxes.cplot(n,data,'k--', 'HitTest', 'Off');
        
        areaaxes.cstem(n,data,'filled','+k', 'HitTest', 'Off'); 
        areaaxes.cstem(n,data+dataerror,'Marker','v','Color','b','LineStyle','none', 'HitTest', 'Off');
        areaaxes.cstem(n,data-dataerror,'Marker','^','Color','b','LineStyle','none', 'HitTest', 'Off');
        
        % THIS SHOULD NOT BE NECESSARY ANY MORE. REMOVE SOON!
        % this property is lost everytime you plot something. why? you 
        % know, because that's why.
        % set(areaaxes, 'ButtonDownFcn', @areaaxesclick)
        
       % imagesc(log(handles.seriesarea)');
        handles = gui_status_update('cs_selected', 1, handles);
        guidata(hObject,handles);
        
%        set(ListSeries,'String',serieslist);
        
    end

    function export_series_spec(hObject,~)
        handles=guidata(hObject);
        
        ixlist=get(ListSeries,'Value');
        ix = ixlist(1);
        
         % retrieve the name of the series to be exported
        seriesstring = get(ListSeries, 'String');
        seriesname = seriesstring{ix};
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_' seriesname '_spec.txt'];
        
        [filename, pathname] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            j=1;
            exportindex=[];
            for i=1:size(handles.seriesarea,1)
                if ~isnan(handles.seriesarea(i,ix))
                    n(j)=i-1;
                    exportindex(j)=handles.seriesindex(i,ix);
                    j=j+1;
                end
            end
                        
            massaxis=handles.peakdata(:,1)';
            rawspec=handles.peakdata(:,2)';
                                   
            resolutionaxis=resolutionbycalibration(handles.calibration,massaxis);
            
            seriesspec=multispec(handles.molecules(exportindex),...
                resolutionaxis,...
                0,...
                massaxis,...
                handles.calibration.shape);
            
            %DELETE THIS!!
            mtemp=handles.molecules(exportindex);
            subtractidx=2;
            for i=1:length(mtemp)
                mtemp(i).area=handles.molecules(exportindex(subtractidx)).area;
            end
            seriestosubtract=multispec(mtemp,...
                resolutionaxis,...
                0,...
                massaxis,...
                handles.calibration.shape);
            %-------------
            
            %write title line
            fid=fopen(fullfile(pathname,filename),'w');
            fprintf(fid,'Mass (Dalton)\tSignal (a.u.)\t%s\t%s contrib\n',seriesname,handles.molecules(exportindex(subtractidx)).name);
            fclose(fid);

            %append data
            dlmwrite(fullfile(pathname,filename),[massaxis',rawspec',seriesspec',seriestosubtract'],'-append','delimiter','\t','precision','%e');
           
        end 
    end

    function sortlistclick(hObject,~)
        handles=guidata(hObject);
        
        searchstring=get(e_searchstring,'String');        
        [handles.seriesarea,handles.seriesareaerror,handles.seriesindex,serieslist]=sortmolecules(handles.molecules,searchstring,handles.peakdata);
        guidata(hObject,handles);
        
        set(ListSeries,'Value',1);
        set(ListSeries,'String',serieslist);
                       
        %reset area plot
        cla(areaaxes.axes);
        listseriesclick(Parent,0)
    end

    function menuloadmoleculesfolder(hObject,~)
        handles=guidata(Parent);
        folder=uigetdir();
        
        if length(folder)>1 %cancel returns folder=0
            handles.molecules=load_molecules_from_folder(folder,foldertolist(folder),handles.peakdata);
            guidata(Parent,handles);
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        handles = gui_status_update('molecules_loaded', 1, handles);
        handles = gui_status_update('changed', 1, handles);
    end

    function menuloadmoleculesif(hObject,~)
        handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.ifd;*.ifm','IsotopeFit files (*.ifd,*.ifm)'},...
            'Load IsotopeFit molecules');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            [~,~,suffix]=fileparts(filename);
            switch lower(suffix)
                case '.ifm'
                    handles.molecules=load_molecules_from_ifm(fullfile(pathname,filename),handles.peakdata);
                    
                    guidata(Parent,handles);
                    
                    molecules2listbox(ListMolecules,handles.molecules);
                case '.ifd'
                    data={}; %load needs a predefined variable
                    load(fullfile(pathname,filename),'-mat');
                    
                    % need to check if any of the molecules are out of range and
                    % remove them
                    handles.molecules = remove_out_of_range_molec(data.molecules, handles.peakdata);
                    
                    
                    guidata(Parent,handles);
                    
                    molecules2listbox(ListMolecules,handles.molecules);
                    
                    
                    % check if massrange (handles.peakdata) of new spec is larger than
                    % massrange of spec that we load the data from (data.raw_peakdata)
                    % --> need to re-load molecules for entire massrange
                    if data.raw_peakdata(end,1)<handles.peakdata(end,1)
                        msgbox(sprintf('Spectrum is larger than spectrum molecules have been loaded from.  \n Probably molecules in higher massrange could not be loaded.'),'Warning', 'Warn');
                    end
            end
            
            handles = gui_status_update('molecules_loaded', 1, handles);
            handles = gui_status_update('changed', 1, handles);
        end
    end

    function menugenerateifm(hObject,~)
         handles=guidata(Parent);
        [filename, pathname, filterindex] = uigetfile( ...
            {'*.*','Generate script (*.*)'},...
            'Open generate script');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
                [ifmfolder,ifmfile]=generate_from_file(fullfile(pathname,filename));
                
                ifmfullfile=['molecules/' ifmfolder '/' ifmfile '.ifm'];                
                
                
                %load the molecules
                % is a file loaded?
                if handles.status.guistatusvector(1) == 1
                    result = questdlg(sprintf('Molecules saved to %s.\nDo you want to load these molecules?',ifmfullfile), 'Load Molecules?');
                    if strcmp(result,'Yes')
                        handles.molecules=load_molecules_from_ifm(ifmfullfile,handles.peakdata);
                        
                        guidata(Parent,handles);
                        molecules2listbox(ListMolecules,handles.molecules);
                        
                        handles = gui_status_update('molecules_loaded', 1, handles);
                        handles = gui_status_update('changed', 1, handles);
                    end
                else
                    msgbox(sprintf('Molecules saved to %s.\nMolecules could not be loaded. Please load a spectrum first.',ifmfullfile), 'Load Molecules?','warn');
                end
        end
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
            
            % Molecules (that are in massrange)
            handles.molecules=remove_out_of_range_molec(data.molecules, handles.peakdata);
            
            % Initialize parameters (necessary because eventually the
            % massaxis has changed
            handles.molecules = init_molecule_properties(handles.molecules,handles.peakdata);
            
            % check if massrange (handles.peakdata) of new spec is larger than
            % massrange of spec that we load the data from (data.raw_peakdata)
            % --> need to re-load molecules for entire massrange
            if data.raw_peakdata(end,1)<handles.peakdata(end,1)
                msgbox(sprintf('Spectrum is larger than spectrum molecules have been loaded from.  \n Probably molecules in higher massrange could not be loaded.'),'Warning', 'Warn');
            end
            
            
            %Calibration data
            handles.calibration=data.calibration;
            
            handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
            handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
            handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
            
            
            guidata(Parent,handles);
            
            molecules2listbox(ListMolecules,handles.molecules);
        end
        
        handles = gui_status_update('molecules_loaded', 1, handles);
        handles = gui_status_update('calibrated', 1, handles);
        handles = gui_status_update('changed', 1, handles);
    end

    function menubgcorrection(hObject,~)
        handles=guidata(Parent);
        temp = handles.bgcorrectiondata;
        [handles.bgcorrectiondata, handles.startind, handles.endind]=bg_correction(handles.raw_peakdata,handles.bgcorrectiondata);    
        
        % need comparison if calibration process changed bgcorrection data.
        % Only if so gui_status_vector should be changed.
        if ~isequal(temp,handles.bgcorrectiondata)
            handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
            handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
            
            % run calibration again, because it is lost, when the background
            % correction is applied
            handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);
            
            guidata(Parent,handles);
            handles = gui_status_update('bg_corrected', 1, handles);
            handles = gui_status_update('fitted', 0, handles);
            handles = gui_status_update('changed', 1, handles);
        end
    end

     function menusmoothmassaxis(hObject,~)
        %needed to solve problems with noisy massaxis
        handles=guidata(Parent);
        
        indaxis=1:size(handles.raw_peakdata,1);
        
        %find a polynom that fits the massaxis       
        p=polyfit(indaxis,handles.raw_peakdata(:,1)',2);

        smoothmass=p(3)+p(2)*indaxis+p(1)*indaxis.^2;
        
        %crop the data -> start from minimum
        [~,minind]=min(smoothmass);
                
        handles.raw_peakdata=handles.raw_peakdata(minind+1:end,:);
        handles.raw_peakdata(:,1)=smoothmass(minind+1:end)';
        
        handles.peakdata=handles.raw_peakdata;
        
        %reset crop values
        handles.startind=1;
        handles.endind=size(handles.peakdata,1);
        
        guidata(Parent,handles);
        
        msgbox('Done.');
     end

    function menupeakdata2raw(hObject,~)
        % function saves peakdata of calibrated spec to raw file (in case
        % you need to perform a second calibration)
        handles=guidata(Parent);
        
        handles.raw_peakdata=handles.peakdata;
        
        %set bgcorrection and calibration to zero
        handles.bgcorrectiondata.bgy=zeros(size(handles.bgcorrectiondata.bgy));
        handles.calibration.massoffsetlist=zeros(size(handles.calibration.massoffsetlist));
        
        guidata(Parent,handles);
        
        msgbox('Done.');
    end

    function menupeakshape(hObject,~)
        handles=guidata(Parent);
                
        limits = get(dataaxes.axes, 'XLim');
        
        %find molecules that are in current view
        moleculelist=molecules_in_massrange_with_sigma(handles.molecules,limits(1),limits(2),handles.calibration,handles.settings.searchrange);
        
        minind=mass2ind(handles.peakdata(:,1)',limits(1));
        maxind=mass2ind(handles.peakdata(:,1)',limits(2));
        
        %check if spectrum is fitted
        if handles.status.guistatusvector(7)==0 % not fitted
            result = questdlg('Spectrum is not fitted. Do you want me to fit the molecules in the current view?', 'Not fitted!');
            switch result
                case 'Yes'
                    deltar=handles.settings.deltaresolution/100;
                    deltam=handles.settings.deltamass;
                    
                    %be careful: don't double-calibrate masses!
                    %set massoffset to zero for final fitting:
                    calibrationtemp=handles.calibration;
                    calibrationtemp.massoffsetmethode='Flat';
                    calibrationtemp.massoffsetparam=0;
                    
                    handles.molecules(moleculelist)=fitwithcalibration(...
                        handles.molecules(moleculelist),...
                        handles.peakdata(minind:maxind,:),...
                        calibrationtemp,...
                        get(ListMethod,'Value'),...
                        handles.settings.searchrange,...
                        deltam,...
                        deltar,...
                        handles.settings.fittingmethod_main);
                case 'Cancel'
                    return;
            end
        end    
        
        calibrationtemp=handles.calibration;
        handles.calibration=peak_shape_generator(handles.peakdata(minind:maxind,:),handles.molecules(moleculelist),handles.calibration);
        
        if ~isequal(calibrationtemp,handles.calibration)
            % set fitted in status update to 0 
            handles = gui_status_update('fitted', 0, handles);
        end
        
        guidata(Parent,handles);
        
    end

    function menucalibration(hObject,~)
        handles=guidata(Parent);
        
        
        if handles.status.rootindexchanged
            %restore rootindex
            h=waitbar(0,'Restoring root-index');
            for i=1:length(handles.molecules)
                handles.molecules(i).rootindex=i;
                waitbar(i/length(handles.molecules));
            end
            close(h);
            handles.status.rootindexchanged = 0;
            guidata(Parent,handles);
        end
        
        peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
        peakdata=subtractbg(peakdata,handles.bgcorrectiondata);
        
        temp = handles.calibration;
        [handles.calibration,handles.molecules]= calibrate(peakdata,handles.molecules,handles.calibration,handles.settings);

        % need comparison if calibration process changed calibration data.
        % Only if so gui_status_vector should be changed
        if ~isequal(temp, handles.calibration)
            handles.peakdata=subtractmassoffset(peakdata,handles.calibration);
            guidata(Parent,handles);
            handles = gui_status_update('calibrated', 1, handles);
            handles = gui_status_update('fitted', 0, handles);
            handles = gui_status_update('changed', 1, handles);
        end
    end

    function load_h5(pathname,filename)
        init();
        handles=guidata(Parent);
        % h5 files carry a mass axis (created and the time of measurement) 
        % and a calibration (created possibly later). the two aren't
        % necessarily the same. we ask the user which one he/she'd like
        question = 'Do you want to use the mass axis or use the calibration of the h5-file to create a new one? If in doubt, choose calibration.';
        userselection = questdlg(question,'title','Calibration','Mass Axis','Calibration');
        
        if strcmp(userselection, 'Mass Axis')
            mass = h5read(fullfile(pathname,filename),'/FullSpectra/MassAxis');
        else
            mass = h5cal(fullfile(pathname,filename));
        end
        
        % read signal
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
        
        % this is maybe not needed anymore
        % but make assurance double sure!
        handles = gui_status_update('file_loaded', 1, handles);
        handles = gui_status_update('calibrated', 0, handles);
        handles = gui_status_update('molecules_loaded', 0, handles);
    end

    function load_ascii(pathname,filename)
        init();
        handles=guidata(Parent);
        % check if this is a file from tofdaq
        fid = fopen(fullfile(pathname,filename));
        teststring = textscan(fid, '%s', 3);
        fclose(fid);
        tofdaqfile = 0;
        % FUCK MATLAB
        anothervariable = teststring{1};
        
        % this is kind of a signature for tofdaq files
        if strcmp(anothervariable{1}, 'mass') && strcmp(anothervariable{2}, 'spectrum') && strcmp(anothervariable{3}, '=============')
            tofdaqfile = 1;
        end
        
        % are we dealing with a tofdaqfile?
        if tofdaqfile == 1
            % yes, remove second column
            tmpvar = dlmread(fullfile(pathname,filename), '\t', 13, 0);
            handles.raw_peakdata = zeros(size(tmpvar, 1), 2);
            handles.raw_peakdata(:, 1) = tmpvar(:, 1);
            handles.raw_peakdata(:, 2) = tmpvar(:, 3);
        else
            % no, read normally
            % handles.raw_peakdata = load(fullfile(pathname,filename));
            handles.raw_peakdata = dlmread(fullfile(pathname,filename), '\t', 2, 0);
        end
        
        handles.startind=1;
        handles.endind=size(handles.raw_peakdata,1);
        handles.peakdata=handles.raw_peakdata;
        
        handles.calibration=standardcalibration;
        
        handles.fileinfo.originalfilename=filename(1:end-4);
        handles.fileinfo.pathname=pathname;
        
        guidata(Parent,handles);
        
        % this is maybe not needed anymore
        % but make assurance double sure!
        handles = gui_status_update('file_loaded', 1, handles);
        handles = gui_status_update('calibrated', 0, handles);
        handles = gui_status_update('molecules_loaded', 0, handles);
    end

    function open_file(hObject, ~, fullpath)
        
        % before opening  new file, check if another file is loaded and if 
        % other file was changed. If yes -> ask "Save file?"
        answer = asksave();
        if strcmp(answer,'Cancel')
            return
        end
        
        % make open file remember the path of previous file 
        handles=guidata(Parent);
        if isfield(handles.fileinfo,'pathname')
            startpathname = handles.fileinfo.pathname;
        else
            startpathname = '';
        end
        
        % most likely this function will not retrieve filename or pathname
        % in this case we show a selection dialog.
        if ~exist('fullpath', 'var')
            [filename, pathname, filterindex] = uigetfile( ...
                {'*.ifd','IsotopeFit data file (*.ifd)';...
                '*.h5','HDF5 data file (*.h5)';...
                '*.h5;*.ifd;*.txt','All files suitable';...
                '*.*','ASCII data file (*.*)'},...
                'Open IsotopeFit data file', startpathname);
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
                    handles=load_ifd(filename,pathname,handles);
                    guidata(Parent,handles);
                    molecules2listbox(ListMolecules,handles.molecules);
                case 2 %h5
                    load_h5(pathname,filename);
                case 4 %ASCII
                    load_ascii(pathname,filename);
            end
            handles=guidata(Parent);
            handles = gui_status_update('file_loaded', 1, handles);
            
            % clear axes
            cla(areaaxes.axes);
            cla(dataaxes.axes);
            
            % plot
            dataaxes.cplot(handles.peakdata(:,1),handles.peakdata(:,2));
            
            % autoscale
            xlim(dataaxes.axes, 'auto');
            ylim(dataaxes.axes, 'auto');
            
            % write filename to visible display:
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
        
        %Default: Gaussian peak shape
        shapes=load('shapes.mat');
        out.shape=shapes.gaussian;
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
            %when molecules are deleted from list, we need to rewrite the
            %molecules rootindex. rootindex is needed for calibration.
            if handles.status.rootindexchanged
                %restore rootindex
                h=waitbar(0,'Restoring root-index');
                for i=1:length(handles.molecules)
                    handles.molecules(i).rootindex=i;
                    waitbar(i/length(handles.molecules));
                end
                close(h);
                handles.status.rootindexchanged = 0;
                guidata(Parent,handles);
            end
            
            % if we autosaved, we don't want that temporary filename to be
            % stored
            if ~strcmp(method,'autosave')
                handles.fileinfo.filename=filename;
                handles.fileinfo.pathname=pathname;
                
                % also belongs in here: if we didn't autosave, we want our
                % status to be "unchanged"
                handles = gui_status_update('changed', 0, handles);
            end
            
            data.raw_peakdata=handles.raw_peakdata;
            data.startind=handles.startind;
            data.endind=handles.endind;
            
            data.molecules=handles.molecules;
            
            data.calibration=handles.calibration;
            data.bgcorrectiondata=handles.bgcorrectiondata;
            
            data.guistatusvector=handles.status.guistatusvector;
            
            data.fileinfo = handles.fileinfo;
            
            save(fullfile(pathname,filename),'data');

            guidata(Parent,handles);
         end
         
        %write filename to visible display:
        set(filenamedisplay, 'String', handles.fileinfo.filename)
        
        % delete backup file since it's not needed anymore
        delete('bkp.ifd')
    end
    
    function remove_molecules(hObject, ~)
        handles = guidata(Parent);
        index = getrealselectedmolecules();
        keep_idx = setdiff(1:length(handles.molecules),index);
        
        %delete molecules
        handles.molecules=handles.molecules(keep_idx);
        
        handles.status.rootindexchanged = 1;
        handles.status.moleculesfiltered = 0;
        guidata(Parent,handles);
                      
        % update listbox
        molecules2listbox(ListMolecules, handles.molecules);
        
        % listbox selection
        if index(1)>length(keep_idx)
            set(ListMolecules, 'Value',length(keep_idx));
        else
            set(ListMolecules, 'Value',index(1));
        end
        
        guidata(Parent,handles);
    end
    
    function moleculelistclick(hObject,~)
        index = getrealselectedmolecules();
        
        % we can always only plot one molecule. if several have been
        % selected we just plot the first one
        if (length(index) >= 2)
            index = index(1);
        end
        
        % set the y-limits to auto
        ylim(dataaxes.axes, 'auto');
        
        % plot the molecule
        plotmolecule(index);
     end

    function areaaxesclick(hObject, eventdata)
        % Reads out click coordinates and finds the corresponding molecule.
        handles=guidata(Parent);

        [x, y] = areaaxes.getclickcoordinates(hObject);
        
        ix1=round(x)+1; % n: row index
        ix2=get(ListSeries,'Value'); % column index
        
        if ~isempty(handles.seriesindex)
            % check if indices are in range (user can click everywhere!!)
            if (ix1>=1)&&(ix1<=size(handles.seriesindex,1))&&...
               (ix2>=1)&&(ix2<=size(handles.seriesindex,2))
                % check if molecule exists
                if handles.seriesindex(ix1,ix2)~=0
                    % FOUND! YEAH!
                    mol_ix=handles.seriesindex(ix1,ix2);
                    
                    plotmolecule(mol_ix);
                    
                    % select molecule in listbox
                    list_ix=mol_ix;
                    if handles.status.moleculesfiltered == 1
                        namelist=get(ListMolecules,'String');
                        list_ix=find(ismember(namelist,handles.molecules(mol_ix).name));
                    end
                    
                    if ~isempty(list_ix) %can be empty, when filter is applied!
                       set(ListMolecules,'Value',list_ix);
                    else
                       %reset filter
                       set(ListFilter,'string','');
                       filterListMolecules([],[]);
                       set(ListMolecules,'Value',mol_ix);
                    end
                   
                end
            end
        end
        
    end

    function dataaxesclick(~, ~)
        % intentionally does nothing
    end

    function filterListMolecules(~,~)
        handles=guidata(Parent);

        % get text to be used as a filter
        filtertext = get(ListFilter,'string');
        
        % check if our filtertext is empty
        if ~isempty(filtertext)
            % Get text for all molecules
            listboxText = {handles.molecules.name};
            
            set(ListMolecules, 'Value', 1);

            % filter
            cellArrayOfMatches = strfind(listboxText,filtertext);
            arrayOfMatches = cellfun(@(x) ~isempty(x), cellArrayOfMatches);

            % create new listbox text
            newListMoleculesText = listboxText(arrayOfMatches);
            set(ListMolecules,'string', newListMoleculesText);
            
            handles.status.moleculesfiltered = 1;
        else
            % it's empty. we just fill the Listbox with all molecules
            % check first if ListMolecules is empty
            if ~isempty(get(ListMolecules, 'String'))
                % first read out, what is currently selected
                curr_ind = getrealselectedmolecules();
            else
                curr_ind = 1;
            end
            
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
        
        limits=get(dataaxes.axes,'xlim');
        % clear axes
        cla(dataaxes.axes)
        
        if index~=0
            % "Normal" mode: zoom to clicked molecule
            ind = findmassrange(handles.peakdata(:,1)',handles.molecules(index),resolutionbycalibration(handles.calibration,handles.molecules(index).com),0,30);
        else
            % Refresh view: plot molecules of actual massrange
            ind = mass2ind(handles.peakdata(:,1),limits(1)):mass2ind(handles.peakdata(:,1),limits(2));
            index = getrealselectedmolecules();
            index = index(1); %in case if there is more than one m. selected
        end
        
        % corresponding mass values of axis
        calcmassaxis=handles.peakdata(ind,1)';
        
        resolutionaxis=resolutionbycalibration(handles.calibration,calcmassaxis);
        
        % calculate fitted spec for 1 (chosen) molecule
        calcsignal=multispec(handles.molecules(index),...
            resolutionaxis,...
            0,...
            calcmassaxis,...
            handles.calibration.shape);
        
        % plot data (= calibrated raw data)
        dataaxes.cplot(handles.peakdata(:,1)',handles.peakdata(:,2)','Color',[0.5 0.5 0.5]);
        
        % plot fitted data for all peaks that are displayed (need to find out which molecules are involved in this range)
        
        limits = [calcmassaxis(1) calcmassaxis(end)];
        
        involvedmolecules=molecules_in_massrange(handles.molecules, limits(1), limits(2));
        
        % calculated fitted spec for all involved molecules
        sumspectrum=multispec(handles.molecules(involvedmolecules),...
            resolutionaxis,...
            0,...
            calcmassaxis,...
            handles.calibration.shape);
        
        dataaxes.cplot(calcmassaxis,sumspectrum,'k--','Linewidth',2);
        dataaxes.cplot(calcmassaxis,calcsignal,'Color','red');
        
        %calculate and plot sum spectrum of involved molecules if current
        %molecule is in calibrationlist
        
        %Zoom data
        %[~,i]=max(handles.molecules(index).peakdata(:,2));
        %       calcmassaxis
        xlim(dataaxes.axes,[limits(1),limits(2)]);
        %ylim(previewaxes,[0,max(max(handles.molecules(index).peakdata(:,2)),max(handles.peakdata(handles.molecules(index).minind:handles.molecules(index).maxind,2)))]);
        
        % Update the slider bar accordingly:
        dataaxes.updateslider;
        
        % set the displays
        % note this is not the nominal mass
        set(comdisplay, 'String', num2str(handles.molecules(index).com));
        set(areadisplay, 'String', num2str(handles.molecules(index).area));
        res = resolutionbycalibration(handles.calibration,handles.molecules(index).com);
        set(resolutiondisplay, 'String', num2str(res));
        
        guidata(Parent,handles);
    end
    
    function [areaout_sorted,areaerrorout_sorted,indexout_sorted,sortlist_sorted]=sortmolecules(molecules,searchstring,peakdata)
        searchstring=['[' searchstring ']'];
        
        attached={};
        t_start = tic;
        show_waitbar = 0;
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
            %b=sqrt(molecules(i).com);
            
            %Area under peak
            %b=1;
            
            %Total number of counts:
            minind=max(1,molecules(i).minind-10);
            maxind=min(size(peakdata,1),molecules(i).maxind+10);
            
            b=(peakdata(minind,1)-peakdata(maxind,1))/...
              (minind-maxind);
              
            
            areaout(lineix,rowix)=molecules(i).area/b;
            %areaerrorout(lineix,rowix)=sqrt(molecules(i).area/b);
            areaerrorout(lineix,rowix)=molecules(i).areaerror/b;
            indexout(lineix,rowix)=i; %save index to molecule
            
            
            
            if toc(t_start) > 0.5 && show_waitbar == 0
                show_waitbar = 1;
                h= waitbar(0, 'Please wait...');
            end
            if show_waitbar==1
                waitbar(i/length(molecules));
            end
        end
        % preallocate for speed
        sortlist = cell(1, length(attached));
        for i=1:length(attached)
            sortlist{i}=[searchstring 'n' attached{i}(1:end-1)];
        end
        
        %sort serieslist alphabetically
        [sortlist_sorted,ix_sorted] = sort(sortlist);
        
        %sort other outputs according to serieslist
        areaout_sorted = areaout(:,ix_sorted);
        areaerrorout_sorted =areaerrorout(:,ix_sorted);
        indexout_sorted = indexout(:,ix_sorted);
        
        %
        areaout_sorted(indexout_sorted==0)=NaN;
        areaerrorout_sorted(indexout_sorted==0)=NaN;
        
        if show_waitbar==1
            close(h);
        end
    end

%     function geterrors(hObject,~)
%         handles=guidata(hObject);
%         massoffset=0;
%         
%         h=waitbar(0,'Busy...');
%         l=length(handles.molecules);
%         
%         %for i=1:l
%         i=78
%         
%             fprintf('Molecule %i/%i: %s\n',i,l,handles.molecules(i).name);
%             resolution=resolutionbycalibration(handles.calibration,handles.molecules(i).com); %resolution
%             
%             involved=molecules_in_massrange_with_sigma(handles.molecules,handles.peakdata(handles.molecules(i).minind,1),handles.peakdata(handles.molecules(i).maxind,1),handles.calibration,handles.settings.searchrange)';
%                         
%             ind=findmassrange2(handles.peakdata(:,1)',handles.molecules(involved),resolution,massoffset,3);%handles.settings.searchrange);
%                         
%             handles.molecules(i).areaerror=get_fitting_error(handles.peakdata(ind,2)',handles.peakdata(ind,1)',handles.molecules(i),handles.molecules(setdiff(involved,i)),handles.calibration);
%             handles.molecules(i).areaerror
%             handles.molecules(i).area
%             
%             guidata(hObject,handles);
%             waitbar(i/l);
%         %end
%         close(h);
%     end

    function export_energy_scan(hObject,eventdata)
        handles=guidata(hObject);
        
        % ====================================== Check for h5 file
        % load file
        if isfield(handles.fileinfo,'h5completepath')
            if exist(handles.fileinfo.h5completepath,'file')
                fn = handles.fileinfo.h5completepath;
            else
                choices = questdlg('h5-File not found. Do you want to select one?', 'Select file?', 'Yes', 'No', 'No');
                switch choices
                    case 'Yes'
                        [filename, pathname, ~] = uigetfile({'*.h5','HDF5 data file (*.h5)';});
                        if ~(isequal(filename,0) || isequal(pathname,0))                        
                            fn = fullfile(pathname,filename);
                            handles.fileinfo.h5completepath = fn;
                            guidata(hObject,handles);
                        else
                            return
                        end
                    case 'No'
                        return;
                end
            end
        else
            choices = questdlg('No original h5-File is known. Do you want to select one?', 'Select file?', 'Yes', 'No', 'No');
            switch choices
                case 'Yes'
                        [filename, pathname, ~] = uigetfile({'*.h5','HDF5 data file (*.h5)';});
                        if ~(isequal(filename,0) || isequal(pathname,0))                        
                            fn = fullfile(pathname,filename);
                            handles.fileinfo.h5completepath = fn;
                            guidata(hObject,handles);
                        else
                            return
                        end
                    case 'No'
                        return
            end
        end
        
        % =========================== Save energies to ASCII file
        
        filenamesuggestion = [handles.fileinfo.pathname handles.fileinfo.filename(1:end-4) '_energy_scans.txt'];
        
        [filename, pathname] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export data',...
            filenamesuggestion);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            deltar=handles.settings.deltaresolution/100;
            deltam=handles.settings.deltamass;
            
            %be careful: don't double-calibrate masses!
            %set massoffset to zero for final fitting:
            calibrationtemp=handles.calibration;
            calibrationtemp.massoffsetmethode='Flat';
            calibrationtemp.massoffsetparam=0;
                        
            %peakdatatemp=approxpeakdata(handles.peakdata,0.2);%much faster with lower resolution
            peakdatatemp=handles.peakdata;%full resolution
            
            %# get the range value
            range=get(hObject,'Label'); %All molecules or Selected_molecules
            
            % which range should we fit?
             switch range
                 case 'Selected molecules'
                 % indices for all molecules selected
                    index=getrealselectedmolecules();
                    allinvolved=findinvolvedmolecules(handles.molecules,1:length(handles.molecules),index,handles.settings.searchrange,handles.calibration);
                 case 'All molecules'
                    allinvolved=1:length(handles.molecules);
                    index=allinvolved;
             end
                 
            n_writes=getnumberofinstancesinh5(fn,'writes');
            n_bufs=getnumberofinstancesinh5(fn,'buffers');
            
            %ask settings
            prompt = {'Start value for calibration','End value for calibration'};
            dlg_title = 'Axis calibration';
            num_lines = 1;
            def = {'0','100'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            
            energy_axis=linspace(str2double(answer{1}),str2double(answer{2}),n_bufs*n_writes);
            
            ES_mat=zeros(n_bufs*n_writes,length(index));
            
            moltemp=handles.molecules;
            
            handles.bgcorrectiondata
            
            %some values for background correction
            tot_counts=sum(handles.peakdata(:,2));
            bgc_temp=handles.bgcorrectiondata;
            for w=1:n_writes
                w/n_writes
                for b=1:n_bufs
                    peakdatatemp(:,2)=readh5buffer(fn, w, b)';
                    
                    % background correction
%                     bgc_temp.bgy=handles.bgcorrectiondata.bgy*sum(peakdatatemp(:,2))/tot_counts; %adapt bg counts to the total counts for this write
%                     peakdatatemp=subtractbg(peakdatatemp,bgc_temp);
                    
                    % fit the isotope corrected value for each buffer:
                    moltemp(allinvolved)=fitwithcalibration(handles.molecules(allinvolved),peakdatatemp,calibrationtemp,1,handles.settings.searchrange,deltam,deltar,'linear_system_baseline');
                    ES_mat((w-1)*n_bufs+b,:)=[moltemp(index).area]';
                    
%                   You can also simply count the events within the
%                   massrange of the molecules. (not isotope corrected!):
%                       for i=1:length(index)
%                          ES_mat((w-1)*n_bufs+b,i)=sum(peakdatatemp(handles.molecules(index(i)).minind:handles.molecules(index(i)).maxind,2));
%                       end
                end
            end
            
            %correct for total counts per molecule
            dm=diff(handles.peakdata(:,1));
            c_vec=zeros(1,length(index));
            
            %write ASCII file
            %write title line
            fid=fopen(fullfile(pathname,filename),'w');
            fprintf(fid,'Energy\t');
            k=1;
            for i=index
                %calculate c_vec for correction
                c_vec(k)=mean(dm(handles.molecules(i).minind:handles.molecules(i).maxind));
                k=k+1;
                fprintf(fid,'%s\t',handles.molecules(i).name);
            end
            fprintf(fid,'\n');
            fclose(fid);
                      
            %append data
            fprintf('dlmwrite. please wait...');
            dlmwrite(fullfile(pathname,filename),[energy_axis',ES_mat.*repmat(1./c_vec,size(ES_mat,1),1)],'-append','delimiter','\t','precision','%e');
            fprintf(' done.\n');
            
        end %save file dialog
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
        
        %# get the range value
        list = get(ListRange,'String');
        value = get(ListRange,'Value');
        if iscell(list)
            range = list{value};
        else
            range = list(value,:);
        end
        
        % which range should we fit?
        switch range
            case 'All'
                % in the case of Fit all we save the file. it's better to
                % be safe than sorry.
                save_file(hObject,eventdata,'autosave')
                
                handles.molecules=fitwithcalibration(handles.molecules,peakdatatemp,calibrationtemp,get(ListMethod,'Value'),handles.settings.searchrange,deltam,deltar,handles.settings.fittingmethod_main);
                
                % set fitted in status update to 1 
                handles = gui_status_update('fitted', 1, handles);
                
                % and we're done (bkp.ifd is deleted when file is saved)
            case 'Selected'
                %index consists of a list of molecules.
                %for fitting, we need to find all molecules that overlap
                %with the selected ones
                allinvolved=findinvolvedmolecules(handles.molecules,1:length(handles.molecules),index,handles.settings.searchrange,handles.calibration);
                
                handles.molecules(allinvolved)=fitwithcalibration(handles.molecules(allinvolved),peakdatatemp,calibrationtemp,get(ListMethod,'Value'),handles.settings.searchrange,deltam,deltar,handles.settings.fittingmethod_main);
            case 'View'
                % Only the molecules that are visible in the current view.
                handles=guidata(Parent);
                limits= get(dataaxes.axes, 'XLim');
                
                %find molecules that are in current view
                allinvolved=molecules_in_massrange_with_sigma(handles.molecules,limits(1),limits(2),handles.calibration,handles.settings.searchrange);
        
                handles.molecules(allinvolved)=fitwithcalibration(handles.molecules(allinvolved),peakdatatemp,calibrationtemp,get(ListMethod,'Value'),handles.settings.searchrange,deltam,deltar,handles.settings.fittingmethod_main);
        end
                
        handles = gui_status_update('changed', 1, handles);
        handles = gui_status_update('cs_selected', 0, handles);
        
        %empty area listbox
        set(ListSeries,'Value',1);
        set(ListSeries,'String','');
        
        %clear area axes
        cla(areaaxes.axes);
        
        guidata(hObject,handles);
        
        % in order to plot we call plotmolecule(0), because this function
        % refreshes the curves in the current view
        plotmolecule(0);
    end

    function showlargedeviations(hObject, ~)
        handles=guidata(Parent);

        % we check for a background level in the mass range between 2.1 and
        % 3.9 amu. subsequently we search through backdata that is above
        % the aforementioned background level.
        bg_area = find(handles.peakdata(:,1) < 3.9 && handles.peakdata(:,1) < 2.1);
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
        ylim = get(dataaxes.axes, 'YLim');
        
        % time to draw
        for i = 1:length(sections_masses)
            p = patch([sections_masses(i,1) sections_masses(i,1) sections_masses(i,2) sections_masses(i,2)],...
                      [ylim(1) ylim(2) ylim(2) ylim(1)],...
                      'r',...
                      'Parent', dataaxes.axes);
            set(p,'FaceAlpha',0.4, 'EdgeColor', 'none', 'Parent', dataaxes.axes);
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
        cl = get(dataaxes.axes, 'XLim');
        viewedrange = (cl(2) - cl(1))*2;
        
        maxmass = max(handles.peakdata(:,1));
        
        if (viewedrange <= maxmass && handles.status.overview == 1)
            handles.status.overview = 0;
        end
        
        % are we already in overview?
        if handles.status.overview == 0
            % save the old settings so we can toggle back
            oxl = get(dataaxes.axes, 'XLim');
            oyl = get(dataaxes.axes, 'YLim');
            handles.status.lastlims = [oxl oyl];
            set(dataaxes.axes, 'YLimMode', 'auto');
            set(dataaxes.axes, 'XLimMode', 'auto');
            handles.status.overview = 1;
        elseif handles.status.overview == 1
            % jump back to last settings
            handles.status.lastlims;
            set(dataaxes.axes, 'XLim', [handles.status.lastlims(1) handles.status.lastlims(2)]);
            set(dataaxes.axes, 'YLim', [handles.status.lastlims(3) handles.status.lastlims(4)]);
            handles.status.overview = 0;
        end
        
        % save back
        guidata(Parent,handles);
    end

    function clearall()
        % this function clears everything and is supposed to be called when
        % a new file is loaded.
        
        % clear plots
        cla(dataaxes.axes);
        cla(areaaxes.axes);
        
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
        % before closing file, check if file was changed. If yes -> ask 
        % "Save file?"
        answer = asksave();
        if strcmp(answer,'Cancel')
            return
        end
        
        % finally close
        delete(Parent)
    end

    function result = asksave()
        % get settings
        handles = guidata(Parent);
        
        try
            % is a file loaded?
            if handles.status.guistatusvector(1) == 1
                % has it changed?
                if handles.status.guistatusvector(6) == 1
                    result = questdlg('It seems the file has changed. Do you want to save it?', 'Save file?');
                    switch result
                        case 'Yes'
                            save_file(Parent,'','save');
                    end
                else
                    % need any value for result
                    result = '0';
                end
            else
                result = '0';
            end
        catch
            msgbox('IsotopeFit was not initialized properly. Stopping without saving');
            result = '0';
        end
        
    end
end