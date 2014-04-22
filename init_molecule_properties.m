function out = init_molecule_properties(molecules_in,peakdata)
% out = init_molecule_properties(molecules_in,peakdata)
%   molecules_in: needs molecules_in.peakdata
%                 and   molecules_in.name
%   peakdata: spectral data (experiment)
%
%   adds:
%   molecules.minmass
%   molecules.maxmass
%   molecules.minind
%   molecules.maxind
%   molecules.area
%   molecules.areaerror
%   molecules.com (center of mass)
%   molecules.rootindex (redundant: molecule index, needet for calibration)
%
%   sorts molecules by first mass in peakdata

out=molecules_in;

masses=[];
peaks=[];
massaxis=peakdata(:,1)';
minmasses=zeros(1,length(out));

hwb=waitbar(0,'Initialization of molecule parameters...');
drawnow;
l=length(out);

for i = 1:l
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
    if out{i}.maxind==out{i}.minind %molecule out of massrange
        out{i}.area=0;
    else
        out{i}.area=guessarea(peakdata(out{i}.minind:out{i}.maxind-1,:));
    end
    
    out{i}.areaerror=+inf;
    
    minmasses(i)=out{i}.minmass;
    %filter(minind:maxind)=1;
    if mod(i,10)==0,  waitbar(i/l); end;
end

%sort molecules with correlated startvalues by minind
[~,indices]=sort(minmasses);
out=out(indices);

for i = 1:length(out)
    out{i}.rootindex=i; %needet for molecule grouping
end

close(hwb);

end

