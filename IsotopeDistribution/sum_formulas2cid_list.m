function out = sum_formulas2cid_list(sum_formulas)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

out=zeros(length(sum_formulas),118);

for i=1:length(sum_formulas)
    out(i,:)=sum_formula2cid(sum_formulas{i});
end

end

