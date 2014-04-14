function settings = settingswindow(hObject, ~, action)
    % this function has two possible use cases. when called without an argument
    % it simply reads the config file and returns the struct with the
    % settings. 
    % the parameter action defines what should happen. currently, 'read'
    % read the settings file and immediately returns. any other value shows
    % the window
    
    handles = guidata(hObject);
    
    if strcmp(action, 'read')
        % read config file and return
        handles.settings = readconfig();
        settings = handles.settings;
        return
    end
    
    settings = handles.settings;
    
    Parent = figure( ...
        'MenuBar', 'none', ...
        'ToolBar','figure',...
        'NumberTitle', 'off', ...
        'Name', 'Settings module',...
        'Units','normalized',...
        'CloseRequestFcn',@closeandsave,...
        'Position',[0.4,0.1,0.4,0.8]); 
    
    % ===== CREATE FIELDS FOR SETTINGS STRUCTURE ===== %
    
    % loop through settings handle on two levels
    s_names_1level = fieldnames(handles.settings);
    % how many fields on level 1?
    num_s_names = numel(s_names_1level);
    n = 1;
    for i = 1:num_s_names
        handles.settings.(s_names_1level{i});
        % is there a second level?
        try
            % loop through all fields on the second level
            s_names_2level = fieldnames(handles.settings.(s_names_1level{i}));
            for j = 1:numel(s_names_2level)
                % read complete name
                prefix = s_names_1level(i);
                name = strcat(prefix, '.', s_names_2level(j));

                % value at this point
                value = handles.settings.(s_names_1level{i}).(s_names_2level{j});
                
                % create fields
                handles.settingslabels{n} = createlabel(name, n);
                handles.settingsfields{n} = createfield(value, n);
                n = n + 1;
            end
        % just an outer level
        catch
            name = s_names_1level(i);
            value = handles.settings.(s_names_1level{i});
            handles.settingslabels{n} = createlabel(name, n);
            handles.settingsfields{n} = createfield(value, n);
            n = n + 1;
        end
    end
    
    % ===== CREATE SAVE AND CANCEL BUTTONS ===== %
    
    uicontrol(Parent,'style','pushbutton',...
        'string','Cancel',...
        'Callback',@closeandsave,...
        'Units','normalized',...
        'Position',gridpos(64,32,64-(n-1)*2-2,64-(n-1)*2,1,16,0.01,0.01));
    
    uicontrol(Parent,'style','pushbutton',...
        'string','Save',...
        'Callback',@saveconfig,...
        'Units','normalized',...
        'Position',gridpos(64,32,64-(n-1)*2-2,64-(n-1)*2,17,32,0.01,0.01));
    
    guidata(Parent,handles);
    uiwait(Parent)
    
    function settings = readconfig()
        % This function reads the file config.txt and returns a struct, where
        % settings.VARIABLE = VALUE if the config.txt contains a line:
        % "VARIABLE = VALUE" (without the ").
        fh = fopen('config.txt');
        while ~feof(fh)
            line = strtrim(fgetl(fh));
            if isempty(line) || all(isspace(line)) || strncmp(line,'#',1)
                ; % nothing happening here - comment or empty line
            else
                % split it up at the equal sign
                [var, val] = strtok(line, ' = ');

                % get rid of trailing or leading whitespaces. remove equal sign
                % from value
                var = strtrim(var);
                val = strtrim(strrep(val, ' = ', ''));

                % update struct
                if strfind(var, '.')
                    % second level: settings.a.b
                    [flevel, slevel] = strtok(var, '.');
                    slevel = strrep(slevel, '.', '');
                    settings.(flevel).(slevel) = val;
                else
                    % just first level: settings.a
                    settings.(var) = val;
                end
            end
        end

        % close file
        fclose(fh);
    end
    function saveconfig(hObject, eventdata)
        % this function reads out all fields and saves them to a file and
        % the settings structure.
        
        handles = guidata(Parent);
        
        % how many settings?
        num_settings = size(handles.settingslabels, 2);

        % open config file
        fh = fopen('config.txt', 'w');
        
        % for each settings we write to file and save to the structure
        for i = 1:num_settings
            % read out the fields and labels
            label = get(handles.settingslabels{i}, 'String');
            % Matlab fun fact No 6341: Text fields return cell arrays, Edit
            % fields return chars. Hence the next line only happens once.
            % Matlab fun fact No 6342: strjoin needs the cell array, not
            % the string. Hence the second variable labelstr
            labelstr = label{1};
            
            field = get(handles.settingsfields{i}, 'String');
            
            % write to config file
            writeout = [label ' = ' field];
            fprintf(fh, '%s\r\n', strjoin(writeout));
            
            % update struct
            if strfind(labelstr, '.')
                % second level: settings.a.b
                [flevel, slevel] = strtok(labelstr, '.');
                slevel = strrep(slevel, '.', '');
                handles.settings.(flevel).(slevel) = field;
            else
                % just first level: settings.a
                handles.settings.(labelstr) = field;
            end
        end
        
        % close file
        fclose(fh);
        
        % write back handles
        guidata(Parent,handles);
    end
    function labelinstance = createlabel(name, n)
        % this function creates a label for the settings
        labelinstance = uicontrol(Parent,'Style','Text',...
            'String',name,...
            'Units','normalized',...
            'Position',gridpos(64,32,64-(n-1)*2-2,64-(n-1)*2,1,8,0.01,0.01));
    end
    function fieldinstance = createfield(value, n)
        % this function creates an editable field for the settings
        fieldinstance = uicontrol(Parent,'Style','Edit',...
            'String',value,...
            'Units','normalized',...
            'Position',gridpos(64,32,64-(n-1)*2-2,64-(n-1)*2,9,32,0.01,0.01));
    end
    function closeandsave(hObject, eventdata)
        handles = guidata(Parent);
        settings = handles.settings;
        uiresume(gcbf);
        delete(Parent);
        return
    end
end