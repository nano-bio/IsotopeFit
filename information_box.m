function out_handle = information_box(title,text)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

out_handle = figure('units','pixels','Name',title,'NumberTitle', 'off','position',[500 500 200 50],'windowstyle','modal');
uicontrol('style','text','string',sprintf(text),'units','pixels','position',[10 10 180 30]);
drawnow();
end

