function [folder,file]=generate_from_file(file_in)
% generate_from_file(file)
% uses cluster definitions in [generate_scripts/file] to generate ifm - files
% see generate_scripts/example.txt

h=fopen(file_in);

%set standard values
th=1e-3;
mapprox=1e-4;
c=1;
add_to_name='';

% if there is no file/folder definition in the script,
% use filename as a default value
% the ifm file is copied to IsotopeDistribution/folder/file.ifm
% (this should be changed in the future)
[~,file,~]=fileparts(file_in);
folder=file;


replacename={};
data={};
data.molecules=[];
cid_list=[];
charge_list=[];

fprintf('Cluster ID generation... please wait ...\n');

while ~feof(h)
    % read line from file
    line=fgetl(h);
    i=1;
    % divide line into substrings
    token={};
    while ~isempty(line)
        [token{i},line]=strtok(line);
        i=i+1;
    end
    % parse instructions
    if ~isempty(token) % empty line
        if ~strcmp(token{1}(1),'%') %comment
            switch lower(token{1})
                case 'mapprox'
                    mapprox=str2num(token{2});
                case 'file'
                    file=token{2};
                case 'folder'
                    folder=token{2};
                case 'th'
                    th=str2num(token{2});
                case 'removeoldfile'
                    if exist(['molecules',filesep,folder,filesep,file,'.ifm'])==2
                        fprintf('Old File removed.\n');
                        delete(['molecules',filesep,folder,filesep,file,'.ifm']);
                    end
                case 'altname'
                    replacename{end+1}=token{2};
                    replacename{end+1}=token{3};
                case 'charge' %charge number of the cluster
                    c=str2num(token{2});
                    if length(token)==3
                        add_to_name=token{3};
                    elseif c>1
                        add_to_name=sprintf('_c%i',c);
                    else
                        add_to_name='';
                    end
                otherwise % line consists of a cluster definition
                    namelist={};
                    altnamelist={};
                    nlist={};
                    for i=1:length(token)/2;
                        namelist{i}=token{2*i-1};
                        nlist{i}=eval(token{2*i});
                    end
                    altnamelist=namelist;
                    %replace sum formulas with alternative names
                    for i=1:length(replacename)/2
                        ind=find(ismember(altnamelist,replacename(2*i-1)));
                        if ~isempty(ind)
                            for j=1:length(ind)
                                altnamelist{ind(j)}=replacename{2*i};
                            end
                        end
                    end
                    altnamelist{1}=[altnamelist{1} add_to_name];
                    
                    %generate the clustersnames and cid's
                    [m,cid]=molecules_from_cluster_definition(namelist,nlist,altnamelist);
                    data.molecules=cat(2,data.molecules,m);
                    cid_list=cat(1,cid_list,cid);
                    charge_list=cat(2,charge_list,repmat(c,1,length(m)));
            end
        end
    end
end

%check for double entries
fprintf('\nCheck for double entries... ')
[~,ind]=unique([charge_list', cid_list],'rows','stable');
if length(ind)<size(cid_list,1)
    fprintf('Double definitions found and removed. Check your cluster definitions.\n');
else
    fprintf('None found.\n')
end

fprintf('\nCalculating peakdata...\n');
data.molecules = add_peakdata_to_molecules(data.molecules(ind),charge_list(ind),mapprox,th);
fprintf('done.\n');

fclose(h);

%save to ifm file
if ~isempty(folder)
    %standard location in molecules/folder/file
    folder=['molecules',filesep,folder];
    if ~(exist(folder)==7)
        mkdir(folder);
        fprintf('\nFolder %s generated\n',folder);
    end
    if ~strcmpi(file(end-3:end),'.ifm')
        file=[file,'.ifm'];
    end
    pathandfile=[folder,filesep,file];
    %pathandfile=[folder,filesep,filename,'.ifm'];
else
    %full path to file provided
    pathandfile=filen;
end

save(pathandfile,'data');

end

