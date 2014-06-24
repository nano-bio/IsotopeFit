function out = generate_cluster(folder,clusterlist,nlist,minmassdistance,th,alternativenames,charge)
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
%   charge: possibility to handle multiply charged ions


folder=['molecules',filesep,folder];

if ~(exist(folder)==7)
    mkdir(folder);
    fprintf('Folder %s generated\n',folder);
end

if nargin==5
    alternativenames=clusterlist;
end

if nargin<6
    charge=1;    
end

nfiles=1;
system=zeros(1,length(clusterlist));
offset=system;

fprintf('Generating ');
for i=1:length(alternativenames)-1
    fprintf(' %s +',alternativenames{i});
end
fprintf(' %s clusters... ',alternativenames{end});

for i=1:length(clusterlist)
    cluster{i}.nend=nlist{i}(end);
    cluster{i}.nstart=nlist{i}(1);
    
    cluster{i}.nelements=(cluster{i}.nend-cluster{i}.nstart+1);
    system(i)=length(nlist{i});
    
    cluster{i}.name=alternativenames{i};
    cluster{i}.sumformula=clusterlist{i};
        
    cluster{i}.peakdata{1}=parse_molecule(cluster{i}.sumformula,minmassdistance,th);
    for j=2:cluster{i}.nend
        cluster{i}.peakdata{j}=convolute(cluster{i}.peakdata{j-1},cluster{i}.peakdata{1});
        cluster{i}.peakdata{j}=approx_masses(cluster{i}.peakdata{j},minmassdistance);
        cluster{i}.peakdata{j}=approx_p(cluster{i}.peakdata{j},th);
    end
end

for i=1:prod(system) %number of combinations=product of basis numbers in varible number system
    filename='';
    clusternumbers=ten2variablesystem(i-1,system);
     d=[0 1];
     for j=1:length(clusternumbers);
         multimer_number=nlist{j}(clusternumbers(j)+1);
         if multimer_number>0 %then attach this species
             d=convolute(d,cluster{j}.peakdata{multimer_number});
             d=approx_masses(d,minmassdistance);
             d=approx_p(d,th);
                                       
             filename=[filename '[' cluster{j}.name ']'];
             if multimer_number>1
                 filename=[filename num2str(multimer_number)];
             end
         end
     end
     if ~strcmp(filename,'')
         %multiply charged ions: divide masses by charge
         d(:,1)=d(:,1)/charge;
         dlmwrite([folder filesep filename '.txt'],d,'delimiter','\t','precision','%e');
     end
end

 
fprintf('done\n');

end

