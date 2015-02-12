function generate_from_file(file)
% generate_from_file(file)
% uses cluster definitions in [generate_scripts/file] to generate ifm - files
% see generate_scripts/example.txt

h=fopen(['generate_scripts/' file]);

%set standard values
th=1e-3;
mapprox=1e-4;
c=1;
add_to_name='';
file=strtok(file,'.');
folder=file;


replacename={};
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
                    %generate the clusters
                    generate_cluster_ifm(folder,file,namelist,nlist,mapprox,th,altnamelist,c);
            end
        end
    end
end

fclose(h);

end

