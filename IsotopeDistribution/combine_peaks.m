function out = combine_peaks(distribution,peaknum)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

psum=distribution(peaknum,2)+distribution(peaknum+1,2);
distribution(peaknum,1)=((distribution(peaknum,1)*distribution(peaknum,2))+(distribution(peaknum+1,1)*distribution(peaknum+1,2)))/psum;
distribution(peaknum,2)=psum;

if peaknum+1~=size(distribution,1)
    out=distribution([1:peaknum peaknum+2:end],:);
else
    out=distribution(1:peaknum,:);
end

end

