function out = column_vector(ind,M_list,rec_depth)

if nargin==2
    rec_depth=1;    
end
    
if rec_depth+1==length(M_list)
    out=M_list{rec_depth}*M_list{rec_depth+1}(:,ind);
else
    out=M_list{rec_depth}*column_vector(ind,M_list,rec_depth+1);
end

end

