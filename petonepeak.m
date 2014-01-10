for i=1:10
    m=136.07358*i;
    dlmwrite(['molecules\petpeak' int2str(i) '.txt'],[m 100],'\t');
    m=136.07358*i+1.00783;
    dlmwrite(['molecules\petpeak' int2str(i) 'H.txt'],[m 100],'\t');
end