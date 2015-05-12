function out = find_cid( cid_list,cid )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%out=find(all(cid_list==repmat(cid,size(cid_list,1),1),2));

ind=1:size(cid_list,1);
for i=1:length(cid) 
    %go through columns and remove indices that dont match.
    %this is faster than find(all... because we dont need to compare every
    %number in the cid list.
    ind=ind(cid_list(ind,i)==cid(i));
    if isempty(ind), break; end;
end

out=ind;

end

