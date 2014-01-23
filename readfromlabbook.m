function out = readfromlabbook()
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

layoutlines=10;
layoutrows=3;

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Background correction',...
    'Position',[0.4*scrsz(3),0.4*scrsz(4),0.4*scrsz(3),0.4*scrsz(4)]); 

uicontrol(Parent,'Style','Text',...
    'Tag','TextNEntries',...
    'String','Number of Entries:',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,10,10,1,1,0.01,0.03));

e_entries=uicontrol(Parent,'Style','edit',...
    'Tag','edit_entries',...
    'Units','normalized',...,...
    'String','20',...
    'Background','white',...
    'Position',gridpos(layoutlines,layoutrows,10,10,2,2,0.05,0.025));
         
uicontrol(Parent,'style','pushbutton',...
          'string','Show',...
          'Callback',@show,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,10,10,3,3,0.02,0.02)); 
      
ListEntries=uicontrol(Parent,'Style','Listbox',...
    'Units','normalized',...
    'Position',gridpos(layoutlines,layoutrows,2,9,1,3,0.01,0.01));

uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback',@okclick,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,1,2,2,0.02,0.02)); 

%Update(Parent);


% ############################## END OF LAYOUT


%A=load(file);
handles=guidata(Parent);


% Abspeichern der Struktur 
guidata(Parent,handles); 

show(Parent,0);

uiwait(Parent)

handles=guidata(Parent);

drawnow;

    function okclick(hObject,eventdata)
        %download file
        handles=guidata(hObject);
        mid = handles.f{1, 1}(get(ListEntries,'Value'));
        dlurl = ['http://138.232.72.25/clustof/export/', num2str(mid)];
        dl = urlwrite(dlurl, 'temp.hd5');
                       
        uiresume(Parent);
        guidata(hObject,handles);
        
        close(Parent);
    end

    function show(hObject,eventdata)
        handles=guidata(hObject);
        count = str2num(get(e_entries,'String'));
        
        a = urlread(['http://138.232.72.25/clustof/csv/',num2str(count)]);
        a = sprintf(a);
        
        f = textscan(a, '%u%s%s%s', 'Delimiter', '\t');
        handles.f = f;
        
        for i = 1:count
            mstring = [num2str(f{1, 1}(i)),', ',f{1, 3}{i},':        ',f{1, 2}{i}];
            measurementlist{i}  = mstring;
        end
        
        set(ListEntries, 'String', measurementlist)
        guidata(hObject,handles);
    end

end

