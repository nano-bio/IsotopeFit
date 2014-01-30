A=double(load('test\C70_H2O.txt'));

m=A(:,1)';
y=A(:,2)';

% startmass=944;
% endmass=956;

startmass=m(1);
endmass=m(end);

deltam=0.001;

y=interp1(m,y,startmass:deltam:endmass,'pchip');
m=startmass:deltam:endmass;

% i1=mass2ind(m,startmass);
% i2=mass2ind(m,endmass);
% 
% m=m(i1:i2);
% y=y(i1:i2);

%ys=smooth(y,5);
ys=y;

l=length(ys);

f=[-1:2/(l-1):1]*(1/(2*deltam));
yf=fftshift(fft(ys));

fcut1=0;
fcut2=10;

yf((f<-fcut2)|((f>-fcut1)&(f<fcut1))|(f>fcut2))=0;

plot(f,yf);

length(f)
length(ys)
%plot(f,abs(yf));

ypeak=ifft(ifftshift(yf));
%plot(m,ypeak,'Linewidth',2);

%plot(m,y-bgydata);
