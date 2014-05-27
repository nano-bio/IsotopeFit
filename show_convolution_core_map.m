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

% uicontrol(Parent,'style','pushbutton',...
%           'string','Export...',...
%           'Callback',@export_core,...
%           'Units','normalized',...
%           'Position',gridpos(layoutlines,layoutrows,1,2,16,18,0.01,0.01)); 
      
% ############################## END OF LAYOUT

% handles=guidata(Parent);
% 
% 
% % Abspeichern der Struktur 
% guidata(Parent,handles); 

handles=guidata(Parent);
handles.peakdata=double(peakdata);

prompt = {'Steps:','Windowsize:','Center bins:'};
dlg_title = 'Convolution core map';
num_lines = 1;
def = {'1000','60000','600'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

steps=str2double(answer{1});
window=str2double(answer{2}); %has to be even!
center_bins=str2double(answer{3}); %extract this number of bins around the center of conv. core

h=information_box(dlg_title,'Please wait...');
molecule_stems=create_molecule_stems(molecules,peakdata(:,1)');
close(h);

left_offset=window/2+1;
right_offset=size(peakdata,1)-window/2;

coremap=zeros(center_bins,steps);
h=waitbar(0,'Busy...');
for i=1:steps
    center_bin=round((i-1)*(right_offset-left_offset)/(steps-1)+left_offset);
    ix1=center_bin-window/2;
    ix2=center_bin+window/2-1;

    K=get_convolution_core(peakdata(ix1:ix2,:),molecule_stems(ix1:ix2));
    K=K(round((length(K)-center_bins)/2):round((length(K)-center_bins)/2)+center_bins-1);
    coremap(:,i)=K/max(K);
    waitbar(i/steps);
end
close(h);


[xmesh,ymesh]=meshgrid(peakdata(round((0:steps-1)*(right_offset-left_offset)/(steps-1)+left_offset),1)',(1:center_bins)-center_bins/2);

hold on
cla(axis1);
%imagesc(coremap,'Parent',axis1);
%contour(coremap);
%plot(axis1,K)
h=pcolor(xmesh,ymesh,coremap);
shading interp;
%set(h,'edgecolor','none');



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
