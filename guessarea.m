function out = guessarea(peakdata)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


if length(peakdata)<=1
    out=0;
else
    out=max(0,sum(peakdata(1:end-1,2).*diff(peakdata(:,1))));
end

end

