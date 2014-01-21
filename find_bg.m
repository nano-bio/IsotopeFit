function [bgpolynomout,startind,endind] = find_bg(m,y,nsteps,ndatapoints,polydegree,startmass,endmass)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if startmass>m(1)
    ix1=find(m>=startmass,1);
else
    ix1=1;
end

if endmass<m(end)
    ix2=find(m>=endmass,1);
else
    ix2=length(m);
end

m=m(ix1:ix2);
y=y(ix1:ix2);

ys=smooth(y,2);

%startvalue=1500;
startvalue=1;
l=length(ys);

step=(l-startvalue)/nsteps;
nminima=round(step*ndatapoints/100);

bgm=[];
bgy=[];
for i=1:nsteps;
    signal=y(floor((i-1)*step)+startvalue:floor(i*step)+startvalue);
    [minmasses,ix]=sort(signal);
    minmasses=minmasses(1:nminima);
    ix=ix(1:nminima);
    %bgm(i)=m(floor(((2*i-1)*step+2*startvalue)/2)); %mean mass
    %bgy(i)=mean(minmasses);
    bgm=[bgm,m(ix+floor((i-1)*step)+startvalue-1)];
    bgy=[bgy,minmasses];
end

p=polyfit(bgm,bgy,polydegree);

%plot(bgm,bgy);hold on;

bgydata=zeros(1,length(m));
for i=0:polydegree
    bgydata=bgydata+p(i+1)*m.^(polydegree-i);
end

% massout=m;
% signalout=y;
startind=ix1;
endind=ix2;
bgpolynomout=p;

end

