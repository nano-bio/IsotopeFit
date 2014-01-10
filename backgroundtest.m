A=double(load('C702_H2O.txt'));

m=A(:,1)';
y=A(:,2)';

ys=smooth(y,2);

startvalue=1500;
l=length(ys);

nsteps=10;
step=(l-startvalue)/nsteps;
nminima=round(step/10);


for i=1:nsteps;
    signal=y(floor((i-1)*step)+startvalue:floor(i*step)+startvalue);
    minmasses=sort(signal);
    minmasses=minmasses(1:nminima);
    bgm(i)=m(floor(((2*i-1)*step+2*startvalue)/2)); %mean mass
    bgy(i)=mean(minmasses);
end

p=polyfit(bgm,bgy,2)

bgydata=p(1)*m.^2+p(2)*m+p(3);

dy=diff(y)./diff(m);

% [miny,ix]=sort(y);
% 
% nminima=100;
% 
% minmasses=(m(ix));
% minmasses=minmasses(1:nminima)
% miny=miny(1:nminima)

ix=find(y<0.5);
%plot(m(ix),y(ix));
plot(m,y,m,bgydata);
%plot(m,y-bgydata);


dlmwrite('C702_H2O_bg.txt',[m' (y-bgydata)'],'delimiter','\t','precision','%e')
