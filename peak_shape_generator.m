function calibration_out=peak_shape_generator(peakdata,molecules,calibration)

% ############################## LAYOUT
%read out screen size
scrsz = get(0,'ScreenSize'); 

layoutlines=30;
layoutrows=30;

Parent = figure( ...
    'MenuBar', 'none', ...
    'ToolBar','figure',...
    'NumberTitle', 'off', ...
    'Name', 'Peak Shape Editor',...
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

axes1 = axes('Parent',Parent,...
             'ActivePositionProperty','OuterPosition',...
             'Units','normalized',...
             'ButtonDownFcn',@axesclick,...
             'Position',gridpos(layoutlines,layoutrows,3,layoutlines,1,25,0.08,0.04));

ListPoints=uicontrol(Parent,'Style','Listbox',...
    'Units','normalized',...
    'Callback',@listpointsclick,...
    'Position',gridpos(layoutlines,layoutrows,9,29,25,30,0.01,0.01));

removebutton=uicontrol(Parent,'style','pushbutton',...
          'string','Remove',...
          'Callback',@removebuttonclick,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,7,8,25,30,0.01,0.01)); 

chk_fixed=uicontrol(Parent,'Style','checkbox',...
    'Tag','chk_fixed',...
    'Units','normalized',...
    'String','Keep this point fixed',...
    'Callback',@toggle_fixed_points,...
    'value',0,...
    'Enable','on',...
    'Position',gridpos(layoutlines,layoutrows,5,6,25,30,0.01,0.01));
      
uicontrol(Parent,'style','pushbutton',...
          'string','Fit non-fixed points.',...
          'Callback',@fitpoints,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,3,4,25,30,0.01,0.01)); 


% when OK is pushed uiwait ends 
uicontrol(Parent,'style','pushbutton',...
          'string','OK',...
          'Callback',@okclick,...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,12,14,0.01,0.01)); 

uicontrol(Parent,'style','pushbutton',...
          'string','Export...',...
          'Callback',@export_core,...
          'Enable','off',...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,15,17,0.01,0.01)); 

uicontrol(Parent,'style','pushbutton',...
          'string','Import...',...
          'Callback',@import_core,...
          'Enable','off',...
          'Units','normalized',...
          'Position',gridpos(layoutlines,layoutrows,1,2,18,20,0.01,0.01)); 
% ############################## END OF LAYOUT

handles=guidata(Parent);
handles.peakdata=double(peakdata);
handles.calibration=calibration;

calibration_out=calibration;

handles.fwhm=mean(peakdata(:,1))/resolutionbycalibration(calibration,mean(peakdata(:,1)));

molecule_stems=create_molecule_stems(molecules,peakdata(:,1)');

[handles.K,handles.masses]=get_convolution_core(peakdata,molecule_stems);

%scale peak width to fit model
handles.masses=handles.masses/(2*handles.fwhm);

%scale peak height to fit model
model_max=max(ppval(handles.calibration.shape,handles.masses));
[data_max,max_ix]=max(handles.K);
handles.K=handles.K*(model_max/data_max);

%shift peak shape
handles.masses=handles.masses-(handles.masses(max_ix));

%read x and y values
handles.xvalues=handles.calibration.shape.breaks(2:end-1);
handles.yvalues=ppval(handles.calibration.shape,handles.xvalues);

%List of fixed points
handles.fixedpoints=zeros(size(handles.xvalues));

guidata(Parent,handles);

load_listbox(1);
plotcurves();

uiwait(Parent);

drawnow;


    function load_listbox(new_position)
        handles=guidata(Parent);
        listbox_entries={};
        
        for i=1:length(handles.calibration.shape.breaks)-2
            listbox_entries{i}=sprintf('(%f,%f)',handles.xvalues(i),handles.yvalues(i));
        end    
        
        set(ListPoints,'Value',new_position);
        set(ListPoints,'String',listbox_entries);
    end

    function plotcurves()
        handles=guidata(Parent);
        cla(axes1);
        hold on;
        plot(axes1,handles.masses,handles.K,'color',[0.5 0.5 0.5],'HitTest','Off');
        plot(axes1,handles.masses,ppval(handles.calibration.shape,handles.masses),'color',[0 0 0],'HitTest','Off');
                    
        %find marked point
        marked_ix=get(ListPoints,'value');
        
        ix_all=1:length(handles.xvalues);
        ix_fixed=setdiff(ix_all(handles.fixedpoints==1),marked_ix);
        ix_notfixed=setdiff(ix_all(handles.fixedpoints==0),marked_ix);
        
        plot(axes1, handles.xvalues(ix_fixed),handles.yvalues(ix_fixed),'ko','Color',[0.5 0.5 0.5],'HitTest','Off');
        plot(axes1, handles.xvalues(ix_notfixed),handles.yvalues(ix_notfixed),'ko','HitTest','Off');
        
        plot(axes1, handles.xvalues(marked_ix),handles.yvalues(marked_ix),'ro','HitTest','Off');
        
        set(axes1, 'ButtonDownFcn', @axesclick)
    end

    function export_core(hObject,~)
        handles=guidata(hObject);
 
        filenamesuggestion = sprintf('Core_Mass_%i_to_%i.txt',round(handles.peakdata(1,1)),round(handles.peakdata(end,1)));
        
        [filename, pathname, filterindex] = uiputfile( ...
            {'*.*','ASCII data (*.*)'},...
            'Export convolution core',...
            filenamesuggestion);
        handles=guidata(Parent);
        
        if ~(isequal(filename,0) || isequal(pathname,0))
           dlmwrite(fullfile(pathname,filename),[massses,handles.K],'delimiter','\t','precision','%e');
        end
    end

    function axesclick(hObject,eventdata)
        % Strange: but this seems to work:
        handles=guidata(hObject);
        
        coordinates=get(hObject,'CurrentPoint');
        x=coordinates(1,1);
        y=coordinates(1,2);
        mouseside=get(gcf,'SelectionType');
        
        currentix=get(ListPoints,'Value');        
        switch mouseside
            case 'alt'
                addpoint(x,y);
            case 'normal'
                [rsq,ix]=find_nearest_point(x,y);
                
                if (rsq>25)||(ix==currentix) %move node
                    movepoint(currentix,x,y);
                else %set current node    
                    set(ListPoints,'Value',ix);
                    set(chk_fixed,'Value',handles.fixedpoints(ix));
                    plotcurves();
                end
                fprintf('Left Click\n');
        end
    end

    function movepoint(ix,x,y)
        handles=guidata(Parent);
        
        handles.xvalues(ix)=x;
        handles.yvalues(ix)=y;
        
        guidata(Parent,handles);
        
        update_shape();
    end

    function addpoint(x,y)
        handles=guidata(Parent);
        
        handles.xvalues(end+1)=x;
        handles.yvalues(end+1)=y;
        handles.fixedpoints(end+1)=0;
        
        ixnew=length(handles.xvalues);
        set(ListPoints,'Value',ixnew);
        
        guidata(Parent,handles);
        
        if length(handles.xvalues)==4
            set(removebutton,'Enable','on');
        end
        
        update_shape();
    end

    function removebuttonclick(hObject,~)
        handles=guidata(Parent);
        
        ix=get(ListPoints,'Value');
        
        removepoint(ix);
        
        guidata(Parent,handles);
    end

    function removepoint(ix)
        handles=guidata(Parent);
        
        %We need at least 3 nodes for a peak shape!!!
        if length(handles.xvalues)>3 %no problem, remove node!
            newlist=setdiff(1:length(handles.xvalues),ix);
            
            ixnew=max(ix-1,1);
            set(ListPoints,'Value',ixnew);
            
            handles.xvalues=handles.xvalues(newlist);
            handles.yvalues=handles.yvalues(newlist);
            handles.fixedpoints=handles.fixedpoints(newlist);
            
            guidata(Parent,handles);
            
            update_shape();
        end
        
        if length(handles.xvalues)==3
            set(removebutton,'Enable','off');
        end
    end

    function update_shape()
        handles=guidata(Parent);
        
        ix=get(ListPoints,'Value');
        
        %guarantee increasing x values
        [handles.xvalues,sortix]=sort(handles.xvalues);
        
        handles.yvalues = handles.yvalues(sortix);
        handles.fixedpoints = handles.fixedpoints(sortix);
        
        %first and last point at y=0
        handles.yvalues(1)=0;
        handles.yvalues(end)=0;
        
        %calculate spline
        handles.calibration.shape=pchip([handles.xvalues(1)-1,handles.xvalues,handles.xvalues(end)+1],[0,handles.yvalues,0]);
        
        guidata(Parent,handles);
        
        load_listbox(find(sortix==ix));
        plotcurves();
    end

    function listpointsclick(hObject,~)
        ix=get(ListPoints,'Value');
        set(chk_fixed,'Value',handles.fixedpoints(ix));
        plotcurves();
    end

    function [rsq_out,ix_out]=find_nearest_point(x,y)
        handles=guidata(Parent);
        
        %convert x and y to pixel coordinates
        F=getframe(axes1);
        nrows = size(F.cdata,1);
        ncols = size(F.cdata,2);
        xlimits= get(axes1, 'XLim');
        ylimits= get(axes1, 'YLim');
                
        px = (x-xlimits(1))*ncols/(xlimits(2)-xlimits(1));
        py = (y-ylimits(1))*nrows/(ylimits(2)-ylimits(1));
        
        pxvalues = (handles.xvalues-xlimits(1))*ncols/(xlimits(2)-xlimits(1));
        pyvalues = (handles.yvalues-ylimits(1))*nrows/(ylimits(2)-ylimits(1));
        
        r_squared=(px-pxvalues).^2+(py-pyvalues).^2;
        
        [rsq_out,ix_out]=min(r_squared);
    end

    function fitpoints(hObject,~)
        handles=guidata(Parent);
        
        fixedpoints=handles.fixedpoints;
        %keep first and last 
        fixedpoints(1)=1;
        fixedpoints(end)=1;
        
        n=sum(fixedpoints==0);
        startoffsets=zeros(1,n*2);
        
        startindex=mass2ind(handles.masses,handles.xvalues(1));
        endindex=mass2ind(handles.masses,handles.xvalues(end));
        
        xsearchrange=0.5;
        ysearchrange=1;
        
        ub=[repmat(xsearchrange,1,n),repmat(ysearchrange,1,n)];
        lb=-1*ub;
        
        %X = fmincon(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)
        offsets=fmincon(@(x) msd_spline(x,handles.masses(startindex:endindex),handles.K(startindex:endindex),handles.xvalues,handles.yvalues,fixedpoints),...
                       startoffsets,[],[],[],[],lb,ub,[],optimoptions('fmincon','Algorithm','interior-point'));
                   
        [handles.xvalues,handles.yvalues]=fitoffsets2coordinates(offsets,handles.xvalues,handles.yvalues,fixedpoints);
        
        guidata(Parent,handles);
        update_shape();      
    end

    function out=msd_spline(fitoffsets,masses,K,xvalues,yvalues,fixedpoints)
        % used for fitting
        % fitcoordinates arranged as [x1 x2 x3 ... xn y1 y2 y3 ... yn]
        % these coordinates are varied and the msd to the core is
        % calculated
                        
        [x,y]=fitoffsets2coordinates(fitoffsets,xvalues,yvalues,fixedpoints);
        
        [x,ix]=sort([x(1)-1,x,x(end)+1]);
        y=[0 y 0];
        y=y(ix);
        
        % pchip has a problem, when x values are not distinct
        % remove double entries for evaluation
        mask=[1 (diff(x)~=0)];
        
        out=double(sum((K-pchip(x(mask==1),y(mask==1),masses)).^2));
    end
        

    function [x,y]=fitoffsets2coordinates(fitoffsets,xvalues,yvalues,fixedpoints)
        %moves non-fixed points according to the values in fitoffsets
        fitoffsets=reshape(fitoffsets,length(fitoffsets)/2,2);
       
        x=xvalues;
        x(fixedpoints==0)=x(fixedpoints==0)-fitoffsets(:,1)';

        y=yvalues;
        y(fixedpoints==0)=y(fixedpoints==0)-fitoffsets(:,2)';
    end

    function toggle_fixed_points(hObject,~)
        handles=guidata(Parent);
        
        ix=get(ListPoints,'Value');
        
        handles.fixedpoints(ix)=get(chk_fixed,'Value');
        guidata(Parent,handles);
    end

    function okclick(hObject,~)
        handles=guidata(Parent);        
        
        % Peakshape Renormation:
        % area has to be 1:
        pptemp=ppint(handles.calibration.shape);%Integration
        scale=ppval(pptemp,handles.masses(end));
        
        handles.calibration.shape.coefs=handles.calibration.shape.coefs./scale;
        
        % Maximum at mass = 0
        pptemp=ppdiff(handles.calibration.shape); % calculate derivative
        max_mass=mean(fnzeros(pptemp,[-0.5,0.5])); %find zero crossing
        
        handles.calibration.shape.breaks=handles.calibration.shape.breaks-max_mass(1);
        
        % FWHM has to be 1
        max_signal=ppval(handles.calibration.shape,0);
        pptemp=handles.calibration.shape;
        pptemp.coefs(:,4)=pptemp.coefs(:,4)-max_signal/2;
        
        FWHM_points=mean(fnzeros(pptemp,[-2,2]));
        handles.calibration.shape=peak_width_adaption(handles.calibration.shape,1/(FWHM_points(end)-FWHM_points(1)),1);
        
        % Re-calibrate Resolution:
        handles.calibration.resolutionlist=handles.calibration.resolutionlist./(FWHM_points(end)-FWHM_points(1));
        
        calibration_out=handles.calibration;
        uiresume(Parent);
        close(Parent);
    end

end
