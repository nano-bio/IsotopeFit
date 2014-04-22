function out = generate_cluster_ifm(folder,filename,clusterlist,nlist,minmassdistance,th,alternativenames,charge)
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


folder=['molecules\',folder];
pathandfile=[folder,'\',filename,'.ifm'];

if ~(exist(folder)==7)
    mkdir(folder);
    fprintf('Folder %s generated\n',folder);
end

if nargin==6
    alternativenames=clusterlist;
end

if nargin<7
    charge=1;    
end

%initialize molecules structure
data={};
k=1;

if exist(pathandfile)==2 %then append molecules to this file
   %load data stucture.
   %data.molecules{i}.peakdata... peakdata for every molecule in file
   %data.molecules{i}.name... molecule names
   %data.namelist... names in cell array to use 'ismember' function
   load(pathandfile,'-mat');
   k=length(data.namelist)+1;
else
   data.namelist={};
end
    

nfiles=1;
system=zeros(1,length(clusterlist));
offset=system;

% generate convolutions for every cluster in clusterlist.
% i.e. [C60]1, [C60]2, [C60]3, [CO2]1, [CO2]2, [CO2]3, [CO2]4
% save them in cluster structure
% cluster{1}.name='C60' (alternative name, if exists)
% cluster{1}.sumformula='C60' (sumformula for monomer)
% cluster{1}.peakdata{i}... masses and abundances for [C60]i, i=1..nend

fprintf('Generating ');
for i=1:length(alternativenames)-1
    fprintf(' %s +',alternativenames{i});
end
fprintf(' %s clusters... ',alternativenames{end});

for i=1:length(clusterlist)
    cluster{i}.nend=nlist{i}(end);
    cluster{i}.nstart=nlist{i}(1);
    
    offset(i)=cluster{i}.nstart;
    cluster{i}.nelements=(cluster{i}.nend-cluster{i}.nstart+1);
    system(i)=length(nlist{i});
    
    cluster{i}.name=alternativenames{i};
    cluster{i}.sumformula=clusterlist{i};
    
    %start from momomer, save every clusternumber from 1 to nend in
    %clusters structure (don't care for offset... you need to start convolution from the beginning)
    cluster{i}.peakdata{1}=parse_molecule(cluster{i}.sumformula,minmassdistance,th);
    for j=2:cluster{i}.nend
        cluster{i}.peakdata{j}=convolute(cluster{i}.peakdata{j-1},cluster{i}.peakdata{1});
        cluster{i}.peakdata{j}=approx_masses(cluster{i}.peakdata{j},minmassdistance);
        cluster{i}.peakdata{j}=approx_p(cluster{i}.peakdata{j},th);
    end
end


%cross-convolute different species (i.e. [C60]i[CO2]j)
%multimers for isolated species are already saved in clusters structure
for i=1:prod(system) %number of combinations=product of basis numbers in varible number system
    moleculename='';
    clusternumbers=ten2variablesystem(i-1,system);
    %generate moleculename before convolution and look if it's already stored in file
    for j=1:length(clusternumbers);
        multimer_number=nlist{j}(clusternumbers(j)+1);
        if multimer_number>0
            moleculename=[moleculename '[' cluster{j}.name ']'];
            if multimer_number>1
                moleculename=[moleculename num2str(multimer_number)];
            end
        end
    end
    if (~any(ismember(data.namelist,moleculename)))&&(~strcmp(moleculename,'')) %then convolute     
        d=[0 1];
        for j=1:length(clusternumbers);
            multimer_number=nlist{j}(clusternumbers(j)+1);
            if clusternumbers(j)>0
                d=convolute(d,cluster{j}.peakdata{multimer_number});
                d=approx_masses(d,minmassdistance);
                d=approx_p(d,th);
            end
        end
        d(:,1)=d(:,1)/charge;
        data.molecules{k}.peakdata=d;
        data.molecules{k}.name=moleculename;
        data.namelist{k}=moleculename;
        k=k+1;
    end
end
 
fprintf('done\n');
%update/write ifm file
save(pathandfile,'data');

end

