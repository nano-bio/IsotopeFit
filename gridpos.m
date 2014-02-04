function out = gridpos(nlines,nrows,celllinesmin,celllinesmax,cellrowsmin,cellrowsmax,xdist,ydist)
%gridpos Positions uicontrol elements on a grid
%   I have no fucking clue how this works. Copy another UI element and start
%   messing around with the values until it is where you want it.
%   Basically you define a (completely virtual) grid with the first two values
%   and then align it relative to this grid with the next 4 values.
%   Keep in mind that xdist/ydist spacing parameters are absolute values in
%   weird matlab units.

dl=1/nlines;
dr=1/nrows;

out=[xdist+(cellrowsmin-1)*dr,ydist+(celllinesmin-1)*dl,(cellrowsmax-cellrowsmin+1)*dr-2*xdist,(celllinesmax-celllinesmin+1)*dl-2*ydist];

end

