function [molecules_out,cid_out] = molecules_from_cluster_definition(clusterlist,nlist,alternativenames)

%initialize molecules structure
molecules_out=[];

system=zeros(1,length(clusterlist));

% generate convolutions for every cluster in clusterlist.
% i.e. [C60]1, [C60]2, [C60]3, [CO2]1, [CO2]2, [CO2]3, [CO2]4
% save them in cluster structure
% cluster{1}.name='C60' (alternative name, if exists)
% cluster{1}.sumformula='C60' (sumformula for monomer)
% cluster{1}.peakdata{i}... masses and abundances for [C60]i, i=1..nend

for i=1:length(alternativenames)-1
    fprintf(' %s +',alternativenames{i});
end
fprintf(' %s... ',alternativenames{end});

for i=1:length(clusterlist)
    cluster(i).nend=nlist{i}(end);
    cluster(i).nstart=nlist{i}(1);
    cluster(i).cid=sum_formula2cid(clusterlist{i});

    system(i)=length(nlist{i});%a number system with varible basis
    
    cluster(i).name=alternativenames{i};
    cluster(i).sum_formula=clusterlist{i};
end

cid_out=uint16(zeros(prod(system),118));

fprintf('%i combinations. ',prod(system));

parfor i=1:prod(system) %number of combinations=product of basis numbers in varible number system
    moleculename='';
    sum_formula='';
    clusternumbers=ten2variablesystem(i-1,system);
    
    cid=uint16(zeros(1,118));
    
    for j=1:length(clusternumbers);
        multimer_number=nlist{j}(clusternumbers(j)+1);
        cid=cid+cluster(j).cid*multimer_number;
        if multimer_number>0
            if multimer_number==1
                moleculename=[moleculename '[' cluster(j).name ']'];
                sum_formula=[sum_formula cluster(j).sum_formula];
            else
                moleculename=[moleculename '[' cluster(j).name ']' num2str(multimer_number)];
                sum_formula=[sum_formula '(' cluster(j).sum_formula ')' num2str(multimer_number)];
            end
        end
    end

    molecules_out(i).name=moleculename;
    molecules_out(i).sum_formula=sum_formula;
    molecules_out(i).cid=cid;
    cid_out(i,:)=cid;
end

if isempty(molecules_out(1).name) % the "zero-cluster"
   molecules_out=molecules_out(2:end);
   cid_out=cid_out(2:end,:);
end

fprintf('done.\n');

end

