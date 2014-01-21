function out = loadmolecules(folder,moleculelist,peakdata)
%loadmolecules( moleculelist,massaxis,startvalues )
%Output stucture: out{l} cell array of length l with following fields:
%out.peakdata... [mass, rel.abundance]
%out.name... filename without .txt
%out.area... first guess of molecule abundance via data integration
%out.centerofmass... masscenter of molecule
%out.minmass(maxmass)... minimum (maximum) mass of molecule
%out.minind(maxind)... minimum (maximum) index in spectrum data
%out.useforcal... boolean, 1:use this molecule for massaxis/resolution
%                            calibration

fprintf('Loading molecule peakdata...\n');

minmasses=zeros(1,length(moleculelist));
maxmasses=zeros(1,length(moleculelist));
hwb=waitbar(0,'Loading molecule peakdata...');
drawnow;
l=length(moleculelist);
for i=1:l
    %fprintf('%s ',moleculelist{i});if mod(i,6)==0, fprintf('\n'); end;
    data{i}.peakdata=load([folder '\' moleculelist{i}]);
    data{i}.name=moleculelist{i}(1:end-4);
    minmasses(i)=data{i}.peakdata(1,1);
    maxmasses(i)=data{i}.peakdata(end,1);
    waitbar(i/l);
end

close(hwb);

%look for start and endindex
ix1=find(maxmasses>peakdata(1,1),1);
ix2=find(minmasses>peakdata(end,1),1);
if isempty(ix2)
    ix2=length(moleculelist);
else
    ix2=ix2-1;
end
    

out=data(ix1:ix2);

fprintf('\nDone.\n')

masses=[];
peaks=[];
massaxis=peakdata(:,1)';
minmasses=zeros(1,length(out));

for i = 1:length(out)
    masses=out{i}.peakdata(:,1)';
    peaks=out{i}.peakdata(:,2)';
    
    out{i}.com=sum(masses.*peaks)/sum(peaks);
    %out{i}.useforcal=false;
   
    masses=masses(find(peaks>=0));
    
    out{i}.minmass=min(masses);
    out{i}.maxmass=max(masses);
        
    out{i}.minind=mass2ind(massaxis,out{i}.minmass);
    out{i}.maxind=mass2ind(massaxis,out{i}.maxmass);

    %Area guessing:
    out{i}.area=sum(peakdata(out{i}.minind:out{i}.maxind,2).*diff(peakdata(out{i}.minind:out{i}.maxind+1,1)));
    out{i}.areaerror=+inf;
    
    minmasses(i)=out{i}.minmass;
    %filter(minind:maxind)=1;
    
end

%sort molecules with correlated startvalues by minind
[~,indices]=sort(minmasses);
out=out(indices);

for i = 1:length(out)
    out{i}.rootindex=i; %needet for molecule grouping
end

end

