function out = diag_eco(M_list)
% diag_eco(M_list)
% calculates the diagonal of the matrix multiplication M_list{1}*M_list{2}*...*M_list{n}
% only useful for large matrices that don't fit in the RAM

    n=size(M_list{1},1);
    
    out=zeros(n,1);

    for i=1:n
        out(i)=M_list{1}(i,:)*column_vector(i,M_list(2:end));
    end


end

