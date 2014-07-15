function [moleculesout] = cluster_generator()


addpath('IsotopeDistribution');

% ############################## LAYOUT

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Cluster Generator',...
    'Units','normalized',...
    'pos',[0.4,0.1,0.4,0.5]); 

hTemp = findall(Parent,'tag','Standard.FileOpen');
set(hTemp, 'ClickedCallback',@open_file);

hTemp = findall(Parent,'tag','Standard.SaveFigure');
set(hTemp, 'ClickedCallback',@save_file);

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


% Main Layout
%labels
uicontrol(Parent,'Style','Text',...
    'String','Sum formula',...
    'Units','normalized',...
    'Position',gridpos(18,4,18,18,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','Alt. name',...
    'Units','normalized',...
    'Position',gridpos(18,4,16,16,1,1,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'String','Charge',...
    'Units','normalized',...
    'Position',gridpos(18,4,14,14,1,1,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'String','n (start)',...
    'Units','normalized',...
    'Position',gridpos(18,4,12,12,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','n (end)',...
    'Units','normalized',...
    'Position',gridpos(18,4,10,10,1,1,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'String','Threshold',...
    'Units','normalized',...
    'Position',gridpos(18,4,8,8,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','Mass accuracy',...
    'Units','normalized',...
    'Position',gridpos(18,4,6,6,1,1,0.01,0.01));

%edits
e_sumf=uicontrol(Parent,'Style','edit',...
    'Tag','sumf',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,17,17,1,1,0.01,0.01));
e_altname=uicontrol(Parent,'Style','edit',...
    'Tag','altname',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,15,15,1,1,0.01,0.01));
e_charge=uicontrol(Parent,'Style','edit',...
    'Tag','charge',...
    'Units','normalized',...
    'String','1',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,13,13,1,1,0.01,0.01));
e_nfrom=uicontrol(Parent,'Style','edit',...
    'Tag','nfrom',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,11,11,1,1,0.01,0.01));
e_nto=uicontrol(Parent,'Style','edit',...
    'Tag','nto',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,9,9,1,1,0.01,0.01));
e_th=uicontrol(Parent,'Style','edit',...
    'Tag','th',...
    'Units','normalized',...
    'String','5E-4',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,7,7,1,1,0.01,0.01));
e_mapprox=uicontrol(Parent,'Style','edit',...
    'Tag','mapprox',...
    'Units','normalized',...
    'String','1E-3',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,4,5,5,1,1,0.01,0.01));

uicontrol(Parent,'style','pushbutton',...
          'string','<- Load Parameters',...
          'Callback',@load_node,...
          'Units','normalized',...
          'Position',gridpos(18,4,3,4,2,4,0.02,0.01));

uicontrol(Parent,'style','pushbutton',...
          'string','Add',...
          'Callback',@add_node,...
          'Units','normalized',...
          'Position',gridpos(18,4,4,4,1,1,0.02,0.01));
uicontrol(Parent,'style','pushbutton',...
          'string','Overwrite',...
          'Callback',@update_node,...
          'Units','normalized',...
          'Position',gridpos(18,4,3,3,1,1,0.02,0.01));
      
uicontrol(Parent,'style','pushbutton',...
          'string','Generate ifm...',...
          'Callback',@generate_ifm,...
          'Units','normalized',...
          'Position',gridpos(18,4,1,1,2,2,0.02,0.01));
uicontrol(Parent,'style','pushbutton',...
          'string','Exit',...
          'Callback',@done,...
          'Units','normalized',...
          'Position',gridpos(18,4,1,1,3,3,0.02,0.01));
      
%Tree view

% Root node
root = uitreenode('v0', 'Clusters', 'Clusters', [], false);
a.name='root';
root.UserData=a;
 
% Tree
mtree = uitree('v0', Parent,'Root', root);
drawnow;
set(mtree,'units','normalized');
set(mtree,'position',gridpos(18,4,5,18,2,4,0.01,1e-3));
set(mtree, 'NodeSelectedCallback', @select_node);


% ############################## END OF LAYOUT
% 

handles=guidata(Parent);

%handles.molecules = molecules;
handles.treehandle = root; %handle to selected node
handles.roothandle = root;

handles.molecules = [];

%Abspeichern der Struktur 
guidata(Parent,handles); 

moleculesout=handles.molecules;

uiwait(Parent)

%################### INTERNAL FUNCTIONS
    function generate_ifm(hObject,~)
        handles=guidata(Parent);
        
        [filename, pathname, ~] = uiputfile( ...
                {'*.ifm','IsotopeFit molecule data (*.ifm)'},...
                'Save molecule data','');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            pathname
            filename
            list=get_all_nodes(handles.roothandle);
            for i=1:length(list)
                generate_cluster_ifm([],fullfile(pathname,filename),list(i).sumflist,list(i).nlist,list(i).ud{1}.mapprox,list(i).ud{1}.th,list(i).namelist,list(i).ud{1}.charge);
            end
        end
        guidata(Parent,handles); 
    end

    function add_node(hObject,~)
        handles=guidata(Parent);
        
        %load user data
        ud.sumf=get(e_sumf,'String');
        ud.name=get(e_altname,'String');
        if isempty(ud.name)
            ud.name=ud.sumf;
        end
        ud.nfrom=str2double(get(e_nfrom,'String'));
        ud.nto=str2double(get(e_nto,'String'));
        ud.charge=str2double(get(e_charge,'String'));
        ud.th=str2double(get(e_th,'String'));
        ud.mapprox=str2double(get(e_mapprox,'String'));
                       
                        
        new_node = uitreenode('v0',ud.name, [ud.name,' [',num2str(ud.nfrom),'..',num2str(ud.nto),']'], [], false);
        %set(handles.treehandle,'IsLeaf',false);
        handles.treehandle.add(new_node);
        
        new_node.UserData=ud;
        mtree.reloadNode(handles.treehandle);
        guidata(Parent,handles); 
    end

    function load_node(hObject,~)
        handles=guidata(Parent);
        nodes = hObject.getSelectedNodes;
        handles.treehandle = nodes(1);
        %allchild(handles.treehandle);
        %handles.treehandle.getNodes
                
        ud=handles.treehandle.handle.UserData;

        if ~strcmp(ud.name,'root')
            %load user data
            set(e_sumf,'String',ud.sumf);
            set(e_altname,'String',ud.name);
            
            set(e_charge,'String',num2str(ud.charge));
            set(e_nfrom,'String',num2str(ud.nfrom));
            set(e_nto,'String',num2str(ud.nto));
            set(e_th,'String',num2str(ud.th));
            set(e_mapprox,'String',num2str(ud.mapprox));
        else
            msgbox('Please select a node!','Root selected','warn')
        end

        guidata(Parent,handles); 
    end

    function select_node(hObject,~)
        handles=guidata(Parent);
        nodes = hObject.getSelectedNodes;
        handles.treehandle = nodes(1);
        %allchild(handles.treehandle);
        %handles.treehandle.getNodes
                
        ud=handles.treehandle.handle.UserData;
        
        test=get_all_nodes(handles.treehandle);
        for i=1:length(test)
           test(i).namelist
        end
        guidata(Parent,handles); 
    end

    function path = node2path(node)
        path = node.getPath;
        for i=1:length(path);
            p{i} = char(path(i).getName);
        end
        if length(p) > 1
            path = fullfile(p{:});
        else
            path = p{1};
        end
    end

    function generate_and_exit(hObject,~)
 
        moleculesout=handles.molecules;
        
        drawnow;
        uiresume(gcbf);
        close(Parent);
    end

    function out=get_all_nodes(node_handle)
        ud=node_handle.handle.UserData;
        if node_handle.getChildCount>0 %recursively access every child node
            childrenVector=node_handle.children; %java handles of children
            i=1;
            while childrenVector.hasMoreElements
                h=childrenVector.nextElement;
                list=get_all_nodes(h);
                for j=1:length(list)
                    if strcmp(ud.name,'root')
                        out(i).namelist=list(j).namelist;
                        out(i).sumflist=list(j).sumflist;
                        out(i).ud=list(j).ud;
                        out(i).nlist=list(j).nlist;
                    else
                        out(i).namelist={ud.name, list(j).namelist{:}};
                        out(i).sumflist={ud.sumf, list(j).sumflist{:}};
                        out(i).ud={ud, list(j).ud{:}};
                        out(i).nlist={[ud.nfrom:ud.nto], list(j).nlist{:}};
                    end
                    i=i+1;
                end
            end
        else %recursion ends
            out.namelist={ud.name};
            out.sumflist={ud.sumf};
            out.nlist={[ud.nfrom:ud.nto]};
            out.ud={ud};
        end
    end

end
