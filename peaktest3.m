function peaktest2()
%C60 Data:
A=double(load('test\C70_H2O.txt'));

m=A(:,1)';
yo=A(:,2)';

startmass=940;
endmass=955;

deltam=0.001;

yo=interp1(m,yo,startmass:deltam:endmass,'pchip');
y=smooth(yo,1)';
m=(startmass:deltam:endmass)-startmass;

l=length(y);

%C60 peakshape

%plot(m,y,m,yo);

p=load('Z:\Experiments\STM\matlab\IsotopeFit\IsotopeDistribution\molecules\C60CH4\[C60].txt');

p(:,1)=p(:,1)-p(1,1)+2;

kamm=zeros(1,l);

for i=1:size(p,1);
    ind=find(m>=p(i,1),1)
    kamm(ind)=p(i,2);
    %kamm=kamm+p(i,2)*g(m,p(i,1),deltam/2);
end


kammfft=zeros(1,l);

fn=1/(2*deltam); %Nyquist frequency
f=(0:l-1)*(2*fn)/l-fn; %frequency axis

for i=1:size(p,1)
    kammfft=kammfft+p(i,2)*exp(-1i*2*pi*f*p(i,1));
end

%plot(m,abs(ifft(kammfft)));
%plot(f,abs(fft(kamm)));

%plot(m,kamm,m,y)

kernelreconstructfft=(fft(y)./fft(kamm));

kernelreconstruct=ifft(kernelreconstructfft);

kernelreconstruct=kernelreconstruct-mean(kernelreconstruct(m>6))';
%kernelreconstruct((m<5.5)|(m>6.7))=kernelreconstruct((m<5.5)|(m>6.7));


plot(m,abs(kernelreconstruct));

%plot(m,y,m,yo);

datareconstruct=ifft(fft(y)./fft(kernelreconstruct));

%plot(m,datareconstruct);


end

function out=g(x,x0,sigma)
    out=(1/(sigma*sqrt(2*pi)))*exp(-(1/2)*((x-x0)/sigma).^2);
end