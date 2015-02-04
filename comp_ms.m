function ok = comp_ms(original_data, corrected_data, xaxis, position)
    % this function displays a simple UI to compare two mass specs. it has
    % two buttons and either returns true or false, depending on what is
    % clicked.

    % ===== LAYOUT ===== %

    Parent = figure( ...
        'MenuBar', 'none', ...
        'ToolBar','figure',...
        'NumberTitle', 'off', ...
        'Name', 'Compare Mass Spectra',...
        'Units','normalized',...
        'OuterPosition', position);

    massaxes = dataviewer(Parent, 'compms', gridpos(64,64,4,64,1,64,0.025,0.02), 50, 50, false, []);

    uicontrol(Parent,'style','pushbutton',...
        'string','Cancel',...
        'Callback',@returnfalse,...
        'Units','normalized',...
        'Position',gridpos(64,64,1,3,1,32,0.01,0.01));

    uicontrol(Parent,'style','pushbutton',...
        'string','Ok, looks good!',...
        'Callback',@returntrue,...
        'Units','normalized',...
        'Position',gridpos(64,64,1,3,33,64,0.01,0.01));

    % plot
    cla(massaxes.axes)
    massaxes.cplot(xaxis, original_data, 'r');
    massaxes.cplot(xaxis, corrected_data, 'g');

    ok = false;
    
    uiwait(Parent);
    
    function returntrue(~, ~)
        ok = true;
        close(Parent);
    end

    function returnfalse(~, ~)
        ok = false;
        close(Parent);
    end
end