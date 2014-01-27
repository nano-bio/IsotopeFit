function out = generate_cluster(folder,clusterlist,nlist,minmassdistance,th,alternativenames)
%generate_cluster(folder,clusterlist,nlist,minmassdistance,th,alternativenames)
%   folder...output folder
%   clusterlist... list of molecules i.e. {'C60' 'H2O' 'CO2'}
%   nlist... start- and endnumber of molecules in cluster i.e. {[1,10]
%       [0,2] [0,1]} : generates [C60]1, [C60]1[H2O][CO2], [C60]1[H2O]2[CO2]
%       etc.
%   minmassdistance... mass approximation. masses within this range are addet
%       up to one peak. good values are below 1e-2
%   th... peaks below this threashold are neglected. values around 1e-6
%   alternativenames... voluntary list of alternative names for long
%       molecule formulas

if exist(folder)==0
    mkdir(folder);
    fprintf('Folder %s generated\n',folder);
end

if nargin==5
    alternativenames=clusterlist;
end

nfiles=1;
system=zeros(1,length(clusterlist));
offset=system;

for i=1:length(clusterlist)
    cluster{i}.nend=nlist{i}(2);
    cluster{i}.nstart=nlist{i}(1);
    
    offset(i)=cluster{i}.nstart;
    cluster{i}.nelements=(cluster{i}.nend-cluster{i}.nstart+1);
    system(i)=cluster{i}.nelements;
    
    cluster{i}.name=alternativenames{i};
    cluster{i}.sumformula=clusterlist{i};
        
    cluster{i}.peakdata{1}=parse_molecule(cluster{i}.sumformula,minmassdistance,th);
    for j=2:cluster{i}.nend
        cluster{i}.peakdata{j}=convolute(cluster{i}.peakdata{j-1},cluster{i}.peakdata{1});
        cluster{i}.peakdata{j}=approx_masses(cluster{i}.peakdata{j},minmassdistance);
        cluster{i}.peakdata{j}=approx_p(cluster{i}.peakdata{j},th);
    end
    nfiles=nfiles*cluster{i}.nelements;
end



for i=1:nfiles
    filename='';
    clusternumbers=ten2variablesystem(i-1,system)+offset;
     d=[0 1];
     for j=1:length(clusternumbers);
         if clusternumbers(j)>0
             %d
             %cluster{j}.peakdata(clusternumbers(j))
             d=convolute(d,cluster{j}.peakdata{clusternumbers(j)});
             d=approx_masses(d,minmassdistance);
             d=approx_p(d,th);
             
             filename=[filename '[' cluster{j}.name ']'];
             if clusternumbers(j)>1
                 filename=[filename num2str(clusternumbers(j))];
             end
         end
     end
     if ~strcmp(filename,'')
         dlmwrite([folder '\' filename '.txt'],d,'delimiter','\t','precision','%e');
     end
 end


end

