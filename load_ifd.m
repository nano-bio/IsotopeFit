function handles = load_ifd(filename,pathname,handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data={}; %load needs a predefined variable
load(fullfile(pathname,filename),'-mat');

handles.raw_peakdata=double(data.raw_peakdata);
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

if ~isfield(handles.calibration,'shape') %compatibility: custom peak shapes
    fprintf('Old File. Load gaussian peak shape as default...');
    shapes=load('shapes.mat');
    handles.calibration.shape=shapes.gaussian;
    fprintf(' done\n');
end

handles.peakdata=croppeakdata(handles.raw_peakdata,handles.startind, handles.endind);
handles.peakdata=subtractbg(handles.peakdata,handles.bgcorrectiondata);
handles.peakdata=subtractmassoffset(handles.peakdata,handles.calibration);

% File info
handles.fileinfo.filename=filename;
handles.fileinfo.originalfilename=filename(1:end-4);

% did we save the f5 file at one point?
try
    handles.fileinfo.h5completepath=data.fileinfo.h5completepath;
catch
    fprintf('Original h5 file not known.\n');
end

handles.fileinfo.pathname=pathname;

% Status vector
if ~isfield(data,'guistatusvector')
    fprintf('Old File. No gui status vector found. Setting default value...');
    handles.status.guistatusvector = [1 1 1 1 0 0 1 0]; %see gui_status_update for details
    fprintf(' done\n');
elseif length(data.guistatusvector)~=8
    fprintf('Old File. Wrong status vector length. Setting default value...');
    handles.status.guistatusvector = [1 1 1 1 0 0 1 0]; %see gui_status_update for details
    fprintf(' done\n');
else
    handles.status.guistatusvector = data.guistatusvector;
end


end

