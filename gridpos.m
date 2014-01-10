function out = gridpos(nlines,nrows,celllinesmin,celllinesmax,cellrowsmin,cellrowsmax,xdist,ydist)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dl=1/nlines;
dr=1/nrows;

out=[xdist+(cellrowsmin-1)*dr,ydist+(celllinesmin-1)*dl,(cellrowsmax-cellrowsmin+1)*dr-2*xdist,(celllinesmax-celllinesmin+1)*dl-2*ydist];

end

