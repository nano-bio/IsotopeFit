function show_convolution_core(peakdata,molecules)

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

layoutlines=30;
layoutrows=30;

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Convolution core',...
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

axis1 = axes('Parent',Parent,...
             'ActivePositionProperty','OuterPosition',...
             'Units','normalized',...
             'Position',gridpos(layoutlines,layoutrows,3,layoutlines,1,layoutrows,0.08,0.04));

% when OK is pushed uiwait ends 
uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback',@okclick,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,13,15,0.01,0.01)); 

uicontrol(Parent,'style','pushbutton',...
          'string','Export...',...
          'Callback',@export_core,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,16,18,0.01,0.01)); 
      
% ############################## END OF LAYOUT

% handles=guidata(Parent);
% 
% 
% % Abspeichern der Struktur 
% guidata(Parent,handles); 

handles=guidata(Parent);
handles.peakdata=double(peakdata);

molecule_stems=create_molecule_stems(molecules,peakdata(:,1)');
[handles.K,x]=get_convolution_core(peakdata,molecule_stems);

minfitind=mass2ind(x,-100);
maxfitind=mass2ind(x,100);

f = fit(x(minfitind:maxfitind),handles.K(minfitind:maxfitind),'gauss3');

hold on
cla(axis1);
plot(axis1,x,handles.K,'color',[0.5 0.5 0.5]);
plot(axis1,x,feval(f,x),'k--','linewidth',2);

guidata(Parent,handles);

uiwait(Parent);

drawnow;

    function export_core(hObject,~)
        handles=guidata(hObject);
     
        
        filenamesuggestion = sprintf('Core_Mass_%i_to_%i.txt',round(handles.peakdata(1,1)),round(handles.peakdata(end,1)));
        
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export convolution core',...
            filenamesuggestion);
        handles=guidata(Parent);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
           dlmwrite(fullfile(pathname,filename),[x,handles.K],'delimiter','\t','precision','%e');
        end
    end

    function okclick(hObject,~)
        uiresume(Parent);
        close(Parent);
    end

end
