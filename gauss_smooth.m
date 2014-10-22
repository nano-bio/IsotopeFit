function out = gauss_smooth(M,sigma)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

shiftsearch=[0:(size(M,1)-1)]-size(M,1)/2;
gausspeak=normpdf(shiftsearch,0,sigma);
out=M;

for i=2:size(M,2)
    out(:,i)=ifftshift(ifft(fft(M(end:-1:1,i)).*fft(gausspeak')));
    out(:,i)=out(end:-1:1,i);
end


end

