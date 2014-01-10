function K = kronsum(A,B)
%same as matlab KRON except addition instead of multiplication
if ~ismatrix(A) || ~ismatrix(B)
    error(message('MATLAB:kron:TwoDInput'));
end

[ma,na] = size(A);
[mb,nb] = size(B);

if ~issparse(A) && ~issparse(B)

   % Both inputs full, result is full.

   A = reshape(A,[1 ma 1 na]);
   B = reshape(B,[mb 1 nb 1]);
   K = reshape(bsxfun(@plus,A,B),[ma*mb na*nb]);

else

   % At least one input is sparse, result is sparse.

   [ia,ja,sa] = find(A);
   [ib,jb,sb] = find(B);
   ia = ia(:); ja = ja(:); sa = sa(:);
   ib = ib(:); jb = jb(:); sb = sb(:);
   ik = bsxfun(@plus, mb*(ia-1).', ib);
   jk = bsxfun(@plus, nb*(ja-1).', jb);
   K = sparse(ik,jk,bsxfun(@plus,sb,sa.'),ma*mb,na*nb);
end
