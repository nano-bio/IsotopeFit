function molecules_out = init_molecule_properties(molecules_in,peakdata)
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

molecules_out=molecules_in;

masses=[];
peaks=[];
massaxis=peakdata(:,1)';
minmasses=zeros(1,length(molecules_out));

hwb=waitbar(0,'Initialization of molecule parameters...');
drawnow;
l=length(molecules_out);

out_of_range_ix=[];

for i = 1:l
    masses=molecules_out{i}.peakdata(:,1)';
    peaks=molecules_out{i}.peakdata(:,2)';
        
    %masses=masses(find(peaks>=0));
    
    molecules_out{i}.minmass=min(masses);
    molecules_out{i}.maxmass=max(masses);
    
    if molecules_out{i}.minmass<peakdata(end,1) %molecule in range
        molecules_out{i}.com=sum(masses.*peaks)/sum(peaks);
        
        molecules_out{i}.minind=mass2ind(massaxis,molecules_out{i}.minmass);
        molecules_out{i}.maxind=mass2ind(massaxis,molecules_out{i}.maxmass);
        
        %Area guessing:
        if (molecules_out{i}.maxind-molecules_out{i}.minind)<=1 %integration not possible
            molecules_out{i}.area=0;
        else
            molecules_out{i}.area=guessarea(peakdata(molecules_out{i}.minind:molecules_out{i}.maxind-1,:));
        end
        
        molecules_out{i}.areaerror=+inf;
        
        minmasses(i)=molecules_out{i}.minmass;
        %filter(minind:maxind)=1;
    else %molecule out of range
        fprintf('Molecule %s out of range\n',molecules_out{i}.name);
        out_of_range_ix=[out_of_range_ix,i];
    end
    
    if mod(i,10)==0,  waitbar(i/l); end;
end

in_range_ix=setdiff(1:l,out_of_range_ix);

minmasses=minmasses(in_range_ix);
molecules_out=molecules_out(in_range_ix);

fprintf('\n%i molecules out of massrange\n',length(out_of_range_ix));
fprintf('%i molecules loadet\n',length(in_range_ix));

%sort molecules with correlated startvalues by minind
[minmasses,indices]=sort(minmasses);
molecules_out=molecules_out(indices);

for i = 1:length(molecules_out)
    molecules_out{i}.rootindex=i; %needet for molecule grouping
end

close(hwb);

end

