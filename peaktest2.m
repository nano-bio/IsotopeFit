function peaktest2()
p=load('Z:\Experiments\STM\matlab\IsotopeFit\IsotopeDistribution\molecules\C60CH4\[C60].txt');

massaxis=p(1,1)-10:0.001:p(end,1)+10;

plot(-1:0.001:1,g(-1:0.001:1,0,0.1));
end

function out=g(x,x0,sigma)
    out=(1/(sigma*sqrt(2*pi)))*exp(-(1/2)*((x-x0)/sigma).^2);
end