function out=nelements(n,s)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

out=int64(factorial(n+s-1)/(factorial(n)*factorial(s-1)));


end

