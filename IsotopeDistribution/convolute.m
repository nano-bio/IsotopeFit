function out = convolute(dist1,dist2)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

% s1=size(dist1,1);
% s2=size(dist2,1);
% 
% dist=zeros(s1*s2,2);
% 
% for i=1:s1
%     dist((i-1)*s2+1:i*s2,1)=dist2(:,1)+dist1(i,1);
%     dist((i-1)*s2+1:i*s2,2)=dist2(:,2)*dist1(i,2);
% end

dist(:,1)=kronsum(dist1(:,1),dist2(:,1));%"Kronecker sum"
dist(:,2)=kron(dist1(:,2),dist2(:,2));%Kronecker Tensor Product

out=dist;

end

