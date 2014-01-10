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
for i=1:length(moleculelist)
    fprintf('%s ',moleculelist{i});if mod(i,8)==0, fprintf('\n'); end;
    out{i}.peakdata=load([folder '\' moleculelist{i}]);
    out{i}.name=moleculelist{i}(1:end-4);
end
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
    
    out{i}.minmass=min(masses)-0.3;
    out{i}.maxmass=max(masses)+0.3;
        
    out{i}.minind=mass2ind(massaxis,out{i}.minmass);
    out{i}.maxind=mass2ind(massaxis,out{i}.maxmass);

    %Area guessing:
    out{i}.area=sum(peakdata(out{i}.minind:out{i}.maxind,2).*diff(peakdata(out{i}.minind:out{i}.maxind+1,1)));
    
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

