function out = generate_cluster(folder,cluster1,n1start,n1end,cluster2,n2start,n2end,minmassdistance,th)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

dist1=parse_molecule(cluster1,minmassdistance,th);
dist2=parse_molecule(cluster2,minmassdistance,th);
d1=dist1;

if exist(folder)==0
    mkdir(folder);
    fprintf('Folder %s generated\n',folder);
end

for i=n1start:n1end
    dlmwrite([folder '\(' cluster1 ')' num2str(i) '.txt'],d1,'\t');
    d2=d1;
    for j=n2start:n2end
        d2=convolute(d2,dist2);       
        d2=approx_masses(d2,minmassdistance);
        d2=approx_p(d2,th);
        
        dlmwrite([folder '\(' cluster1 ')' num2str(i) '(' cluster2 ')' num2str(j) '.txt'],d2,'\t');
    end
    d1=convolute(d1,dist1);
    d1=approx_masses(d1,minmassdistance);
    d1=approx_p(d1,th);
    
end


end

