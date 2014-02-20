function peaktest2()
p=load('Z:\Experiments\STM\matlab\IsotopeFit\IsotopeDistribution\molecules\C60CH4\[C60].txt');

p(:,1)=p(:,1)-p(1,1)-12;

massaxis=p(1,1)-20:0.005:p(end,1)+20;

l=length(massaxis);

kamm=zeros(1,l);

for i=1:size(p,1);
    kamm=kamm+p(i,2)*g(massaxis,p(i,1)-0.4,0.001);
end

kernel=g(massaxis,0,0.1)+0.7*g(massaxis,-0.3,0.2);

signal=ifft(fft(kernel).*fft(kamm));
noise=ones(1,l).*(0.5-rand(1,l));
signal=signal+10*noise;

plot(massaxis,signal);

%add noise to original peakdata
kammr=zeros(1,l);
for i=1:size(p,1);
    kammr=kammr+p(i,2)*(1+(0.5-rand())/20)*g(massaxis,p(i,1),0.001);
end

plot(massaxis,kamm,massaxis,kammr)

kernelreconstruct=ifft(fft(signal)./fft(kammr));

plot(massaxis,kernelreconstruct,massaxis,kernel);


end

function out=g(x,x0,sigma)
    out=(1/(sigma*sqrt(2*pi)))*exp(-(1/2)*((x-x0)/sigma).^2);
end