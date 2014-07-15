function [moleculesout] = cluster_generator()

addpath('IsotopeDistribution');

%% ############################## Figure with customized toolbar

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Cluster Generator',...
    'Units','normalized',...
    'pos',[0.4,0.1,0.3,0.5]); 

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


%% ############################################## Main Layout
%labels
uicontrol(Parent,'Style','Text',...
    'String','Sum formula',...
    'Units','normalized',...
    'Position',gridpos(18,3,18,18,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','Alt. name',...
    'Units','normalized',...
    'Position',gridpos(18,3,16,16,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','n (i.e. 1:10 or [1,2,4])',...
    'Units','normalized',...
    'Position',gridpos(18,3,14,14,1,1,0.01,0.01));

uicontrol(Parent,'Style','Text',...
    'String','Charge',...
    'Units','normalized',...
    'Position',gridpos(18,3,11,11,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','Threshold',...
    'Units','normalized',...
    'Position',gridpos(18,3,9,9,1,1,0.01,0.01));
uicontrol(Parent,'Style','Text',...
    'String','Mass accuracy',...
    'Units','normalized',...
    'Position',gridpos(18,3,7,7,1,1,0.01,0.01));

%edits
e_sumf=uicontrol(Parent,'Style','edit',...
    'Tag','sumf',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,17,17,1,1,0.01,0.01));
e_altname=uicontrol(Parent,'Style','edit',...
    'Tag','altname',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,15,15,1,1,0.01,0.01));
e_n=uicontrol(Parent,'Style','edit',...
    'Tag','n',...
    'Units','normalized',...
    'String','',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,13,13,1,1,0.01,0.01));

e_charge=uicontrol(Parent,'Style','edit',...
    'Tag','charge',...
    'Units','normalized',...
    'String','1',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,10,10,1,1,0.01,0.01));
e_th=uicontrol(Parent,'Style','edit',...
    'Tag','th',...
    'Units','normalized',...
    'String','5E-4',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,8,8,1,1,0.01,0.01));
e_mapprox=uicontrol(Parent,'Style','edit',...
    'Tag','mapprox',...
    'Units','normalized',...
    'String','1E-3',...
    'Background','white',...
    'Enable','on',...
    'Position',gridpos(18,3,6,6,1,1,0.01,0.01));


uicontrol(Parent,'style','pushbutton',...
          'string','Add -->',...
          'Callback',@add_node,...
          'Units','normalized',...
          'Position',gridpos(18,3,4,4,1,1,0.02,0.01));
      
uicontrol(Parent,'style','pushbutton',...
          'string','Generate ifm...',...
          'Callback',@generate_ifm,...
          'Units','normalized',...
          'Position',gridpos(18,4,1,2,2,2,0.02,0.01));
uicontrol(Parent,'style','pushbutton',...
          'string','Exit',...
          'Callback',@done,...
          'Units','normalized',...
          'Position',gridpos(18,4,1,2,3,3,0.02,0.01));

%% ################################## Tree view

% Root node
root = uitreenode('v0', 'Clusters', 'Clusters', [], false);
a.name='root';
root.UserData=a;
 
% Tree
mtree = uitree('v0', Parent,'Root', root); %Handle to matlabs uitree
jtree = mtree.getTree; % Handle to Java object (usage of java methods possible)

drawnow;
set(mtree,'units','normalized');
set(mtree,'position',gridpos(18,3,4,18,2,3,0.01,1e-3));
set(mtree, 'NodeSelectedCallback', @select_node);

%% ############################## Tree view context menu

% Prepare the context menu
menuItem_edit = javax.swing.JMenuItem('Edit');
menuItem_del = javax.swing.JMenuItem('Remove');
menuItem_cp = javax.swing.JMenuItem('Copy node');
menuItem_cpst = javax.swing.JMenuItem('Copy subtree');
menuItem_paste = javax.swing.JMenuItem('Paste');
menuItem_append = javax.swing.JMenuItem('Append icg');

% Set the menu items' callbacks
set(menuItem_edit,'ActionPerformedCallback',@edit_node);
set(menuItem_del,'ActionPerformedCallback',@remove_node);
set(menuItem_cp,'ActionPerformedCallback',@copy_node);
set(menuItem_cpst,'ActionPerformedCallback',@copy_subtree);
set(menuItem_paste,'ActionPerformedCallback',@paste_node);
set(menuItem_append,'ActionPerformedCallback',@append_icg);

% Add all menu items to the context menu (with internal separator)
jmenu = javax.swing.JPopupMenu;
jmenu.add(menuItem_edit);
jmenu.addSeparator;
jmenu.add(menuItem_del);
jmenu.add(menuItem_cp);
jmenu.add(menuItem_cpst);
jmenu.add(menuItem_paste);
jmenu.addSeparator;
jmenu.add(menuItem_append);

% Set the tree mouse-click callback
% Note: MousePressedCallback is better than MouseClickedCallback
%       since it fires immediately when mouse button is pressed,
%       without waiting for its release, as MouseClickedCallback does
set(jtree, 'MousePressedCallback', {@mousePressedCallback,jmenu});

%% ############################## END OF LAYOUT


handles=guidata(Parent);

%handles.molecules = molecules;
handles.treehandle = root; %handle to selected node
handles.roothandle = root;

handles.molecules = [];

%Abspeichern der Struktur 
guidata(Parent,handles); 

moleculesout=handles.molecules;

init();

uiwait(Parent)

%% ################### INTERNAL FUNCTIONS
    function init()
        %% Initialization
        handles=guidata(Parent);
        
        handles.clipboard = []; % for copy-paste nodes
        handles.treehandle = handles.roothandle;
        handles.roothandle.removeAllChildren();
        
        guidata(Parent,handles);
    end
    
    function paste_node(hObject,~)
        %% adds node(s) from handles.clipboard to current node 
        handles = guidata(Parent);
        
        struct2tree(handles.treehandle,handles.clipboard);                
        mtree.reloadNode(handles.roothandle);
    end
        
    function copy_node(hObject,~)
        %% saves current node to handles.clipboard
        handles = guidata(Parent);
        
        temp = [];
        
        temp.ud = handles.treehandle.handle.UserData;
        temp.children = [];
        
        if ~strcmp(temp.ud.name,'root')
            % we need to add this node as a child to the root node. first level
            % of struct is not accessed by struct2tree!!!
            handles.clipboard.children = temp;
            handles.clipboard.ud.name = 'root';
        else
            handles.clipboard = [];
            msgbox('Please select a node!','Root selected','warn')
        end
        guidata(Parent,handles);
        
    end

    function copy_subtree(hObject,~)
        %% saves current node to handles.clipboard
        handles = guidata(Parent);
        
        temp = [];
        
        temp = tree2struct(handles.treehandle);
        
        
        if strcmp(temp.ud.name,'root')
            % selected node is root node
            handles.clipboard = temp;
        else
            % we need to add this node as a child to the root node. first level
            % of struct is not accessed by struct2tree!!!
            handles.clipboard.children = temp;
            handles.clipboard.ud.name = 'root';
        end
        
        guidata(Parent,handles);
        
    end

    function mousePressedCallback(hTree, eventData, jmenu)
        %% Fires, when Treeview is clicked
        
        if eventData.isMetaDown  % right-click is like a Meta-button
            handles=guidata(Parent);
            % Get the clicked node
            clickX = eventData.getX;
            clickY = eventData.getY;
            
            % check if there is something stored in clipboard
            if isempty(handles.clipboard)
                menuItem_paste.setEnabled(false);
            else
                menuItem_paste.setEnabled(true);
            end
            
            %some actions are not possible for level 0
            if isempty(handles.treehandle.getParent)
                menuItem_edit.setEnabled(false);
                menuItem_del.setEnabled(false);
                menuItem_cp.setEnabled(false);
            else
                menuItem_edit.setEnabled(true);
                menuItem_del.setEnabled(true);
                menuItem_cp.setEnabled(true);
            end
            
            % Display the (possibly-modified) context menu
            jmenu.show(jtree, clickX, clickY);
            jmenu.repaint;
            guidata(Parent,handles);
        end
    end

    function removeItem(hObj,eventData,jmenu,item)
        %% Remove the extra context menu item after display
        jmenu.remove(item);
    end

    function save_file(hObject,~)
        %% Converts Tree View to struct and saves it to -mat file
        handles=guidata(Parent);
        
        [filename, pathname, ~] = uiputfile( ...
                {'*.icg','IsotopeFit molecule data (*.icg)'},...
                'Save IsotopeFit cluster generator file','');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            data=tree2struct(handles.roothandle);
            save(fullfile(pathname,filename),'data');
        end
        guidata(Parent,handles); 
    end
    
    function append_icg(hObject,~)
        %%
        handles=guidata(Parent);
        
        [filename, pathname, ~] = uigetfile( ...
                {'*.icg','IsotopeFit molecule data (*.icg)'},...
                'Load IsotopeFit cluster generator file','');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            data=[];
            load(fullfile(pathname,filename),'-mat');
            struct2tree(handles.treehandle,data);
            mtree.reloadNode(handles.treehandle);
            drawnow;
        end
        guidata(Parent,handles); 
    end
    
    function open_file(hObject,~)
        %%
        handles=guidata(Parent);
        
        [filename, pathname, ~] = uigetfile( ...
                {'*.icg','IsotopeFit molecule data (*.icg)'},...
                'Load IsotopeFit cluster generator file','');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            handles.roothandle.removeAllChildren()
            data=[];
            load(fullfile(pathname,filename),'-mat');
            struct2tree(handles.roothandle,data);
            mtree.reloadNode(handles.roothandle);
            drawnow;
        end
        guidata(Parent,handles); 
    end

    function generate_ifm(hObject,~)
        %% Generates input for generate_cluster_ifm and saves ifm file
        handles=guidata(Parent);
        
        [filename, pathname, ~] = uiputfile( ...
                {'*.ifm','IsotopeFit molecule data (*.ifm)'},...
                'Save molecule data','');
        
        if ~(isequal(filename,0) || isequal(pathname,0))
            % we need to delete existing files, because
            % generate_cluster_ifm appends the generated data
            if exist(fullfile(pathname,filename))==2
                fprintf('Old File removed.\n');
                delete(fullfile(pathname,filename));
            end
            
            % generate cluster list from tree
            list=get_all_nodes(handles.roothandle);
            
            % start generate_cluster_ifm
            for i=1:length(list)
                generate_cluster_ifm([],fullfile(pathname,filename),list(i).sumflist,list(i).nlist,list(i).ud{1}.mapprox,list(i).ud{1}.th,list(i).namelist,list(i).ud{1}.charge);
            end
        end
        guidata(Parent,handles); 
    end
    
    function set_user_data(node_handle,ud)
        %% reads user data stored in node and writes values to edits

        set(e_sumf,'String',ud.sumf);
        set(e_altname,'String',ud.name);
        set(e_n,'String',ud.n);
        
        set(e_charge,'String',num2str(ud.charge));
        set(e_th,'String',num2str(ud.th));
        set(e_mapprox,'String',num2str(ud.mapprox));
    end

    function ud=load_user_data()
        %% loads user data from edits into a struct
        
        ud.sumf=get(e_sumf,'String');
        ud.name=get(e_altname,'String');
        if isempty(ud.name)
            ud.name=ud.sumf;
        end
        ud.n=get(e_n,'String');
        
        ud.charge=str2double(get(e_charge,'String'));
        ud.th=str2double(get(e_th,'String'));
        ud.mapprox=str2double(get(e_mapprox,'String'));
    end

    function remove_node(hObject,~)
        %% removes selected node from tree
        handles=guidata(Parent);
        
        node=handles.treehandle;
        if ~handles.treehandle.isRoot
            nP = node.getPreviousSibling;
            nN = node.getNextSibling;
            if ~isempty( nN )
                mtree.setSelectedNode( nN );
                handles.treehandle=nN;
            elseif ~isempty( nP )
                mtree.setSelectedNode( nP );
                handles.treehandle=nP;
            else
                h=node.getParent;
                handles.treehandle=h;
                mtree.setSelectedNode(h);
            end
            node.removeFromParent();
            mtree.reloadNode(handles.treehandle.getParent);
        end
        guidata(Parent,handles);
    end

    function add_node(hObject,~)
        %% adds a child to the selected node
        handles=guidata(Parent);
        
        %load user data
        ud=load_user_data;
        
        % create new node: uitreenode(wrapper_version, value, name, icon, IsLeaf);
        new_node = uitreenode('v0',ud.name, [ud.name,' (',ud.n,')'], [], false);
      
        handles.treehandle.add(new_node);
        
        p = handles.treehandle.getParent;
        if ~isempty(p) %level higher than one: inherit cluster parameters from parent!
            ud.charge = handles.treehandle.handle.UserData.charge;
            ud.th = handles.treehandle.handle.UserData.th;
            ud.mapprox = handles.treehandle.handle.UserData.mapprox;
        end
        
        new_node.UserData = ud;
        mtree.reloadNode(handles.treehandle);
        mtree.expand(handles.treehandle);
        guidata(Parent,handles); 
    end

    function update_node(hObject,~)
        %% update node
        handles=guidata(Parent);
        
        % load user data
        ud=load_user_data;
        
        % update name, value and user data.
        handles.treehandle.handle.UserData = ud;
        handles.treehandle.setName([ud.name,' (',ud.n,')']);
        handles.treehandle.setValue(ud.name);
               
        mtree.reloadNode(handles.treehandle);
        mtree.expand(handles.treehandle);
        guidata(Parent,handles); 
    end

    function edit_node(hObject,~)
        %% 
        handles=guidata(Parent);
        ud=handles.treehandle.handle.UserData;
        
        if ~strcmp(ud.name,'root')
            %load user data
            p=handles.treehandle.getParent();
            if strcmp(p.handle.UserData.name,'root') % then mapprox, th and charge can be edited
                prompt = {'Sum formula:','Alternative Name:','n:','Charge','Threshold:','Mass accuracy:'};
                dlg_title = 'Edit node';
                num_lines = 1;
                def = {ud.sumf,ud.name,ud.n,num2str(ud.charge),num2str(ud.th),num2str(ud.mapprox)};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                ud.sumf=answer{1};
                ud.name=answer{2};
                ud.n=answer{3};
                ud.charge=str2double(answer{4});
                ud.th=str2double(answer{5});
                ud.mapprox=str2double(answer{6});
            else
                prompt = {'Sum formula:','Alternative Name:','n:'};
                dlg_title = 'Edit node';
                num_lines = 1;
                def = {ud.sumf,ud.name,ud.n};
                answer = inputdlg(prompt,dlg_title,num_lines,def);
                ud.sumf=answer{1};
                ud.name=answer{2};
                ud.n=answer{3};
            end
            
            %use sum formula as name, when alt. name is empty
            if isempty(ud.name)
                ud.name=ud.sumf;
            end
            
            handles.treehandle.handle.UserData = ud;
            handles.treehandle.setName([ud.name,' (',ud.n,')']);
            handles.treehandle.setValue(ud.name);
            
            mtree.reloadNode(handles.treehandle);
            mtree.expand(handles.treehandle);
            %set_user_data(handles.treehandle,ud);
        else
            msgbox('Please select a node!','Root selected','warn')
        end

        guidata(Parent,handles); 
    end

    function select_node(hObject,~)
        %%
        handles = guidata(Parent);
        nodes = hObject.getSelectedNodes;
        %selection gets lost, when tree is refreshed. But select_node
        %callback fires! we need to check if something is selected
        if ~isempty(nodes)
            handles.treehandle = nodes(1);
            
            %inactivate edits for cluster parameters for children
            p=handles.treehandle.getParent;
            if isempty(p) % root selected
                temp='on';
            else
                temp='off';
            end
            
            set(e_charge,'enable',temp);
            set(e_th,'enable',temp);
            set(e_mapprox,'enable',temp);
            
            guidata(Parent,handles);
        end
    end

    function path = node2path(node)
        %%
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

    function done(hObject,~)
        %%
%         moleculesout=handles.molecules;  
%         drawnow;
        uiresume(gcbf);
        close(Parent);
    end

    function out=get_all_nodes(node_handle)
        %% 
        % Accesses all nodes and generates cell arrays that 
        % can be used as an input for generate_cluster_ifm
        
        ud=node_handle.handle.UserData;
        if node_handle.getChildCount>0 % recursively access every child node
            childrenVector=node_handle.children; % java handles of children
            i=1;
            while childrenVector.hasMoreElements % Access every child
                h=childrenVector.nextElement;
                list=get_all_nodes(h); % RECURSION
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
                        out(i).nlist={eval(ud.n), list(j).nlist{:}};
                    end
                    i=i+1;
                end
            end
        else % Recursion end
            out.namelist={ud.name};
            out.sumflist={ud.sumf};
            out.nlist={eval(ud.n)};
            out.ud={ud};
        end
    end

    function out=tree2struct(node_handle)
        %%
        ud=node_handle.handle.UserData;
        if node_handle.getChildCount>0 %recursively access every child node
            childrenVector=node_handle.children; %java handles of children
            i=1;
            while childrenVector.hasMoreElements
                h=childrenVector.nextElement;
                out.ud=ud;
                out.children(i)=tree2struct(h);
                i=i+1;
            end
        else %recursion ends
            out.ud=ud;
            out.children=[];
        end
    end

    function struct2tree(node_handle,data)
        %%
        for i=1:length(data.children)
            if ~isempty(data.children(i)) %leaves do not have children ;)
                new_node = uitreenode('v0',data.children(i).ud.name, [data.children(i).ud.name,' (',data.children(i).ud.n,')'], [], false);
                node_handle.add(new_node);
                new_node.UserData=data.children(i).ud;
                struct2tree(new_node,data.children(i))
            end 
        end
    end


end
