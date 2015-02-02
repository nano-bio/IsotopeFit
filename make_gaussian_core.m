function out = make_gaussian_core(n_points)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

massaxis=-3:0.01:3;
signal=normpdf(massaxis,0,1/(2*sqrt(2*log(2))));

x_start=0.2;
x_end=2;

hold on;

xvalues=[0:(n_points-1)]/(n_points-1)*(x_end-x_start)+(x_start);

offsets=zeros(size(xvalues));

searchrange=0.5;

ub=ones(size(xvalues))*searchrange;
lb=-1*ub;

for i=1:10
    i
    offsets=fmincon(@(x) msd_spline(x,xvalues,massaxis,signal),...
        offsets,[],[],[],[],lb,ub,[],optimoptions('fmincon','Algorithm','interior-point'));
end         

[xv,yv]=splinepoints(xvalues-offsets,massaxis,signal);
cla;

plot(massaxis,signal,massaxis,interpfcn(xv,yv,massaxis));
plot(xv,yv,'ko');

gaussian=pchip(xv,yv);
save('shapes.mat','gaussian');

%plot(massaxis,signal)

end

function [xout,yout]=splinepoints(xvalues,massaxis,signal)
  xout=[-1*xvalues(end)-1,-1*xvalues(end:-1:1),0,xvalues,xvalues(end)+1];
  
  yout=interp1(massaxis,signal,xout);
  yout(1:2)=[0 0];
  yout(end-1:end)=[0 0];
  

end


function out=msd_spline(xoffsets,xvalues,massaxis,signal)
  [x,y]=splinepoints(xvalues-xoffsets,massaxis,signal);
  
  [x,ix]=sort(x);
  y=y(ix);

  out=sum((signal-interpfcn(x,y,massaxis)).^2);
end

function out=interpfcn(x,y,xx)
  mask=[1 (diff(x)~=0)];

%   pp=spline(x(mask~=0),y(mask~=0));
%   pp.coefs(1,:)=[0 0 0 0];
%   pp.coefs(end,:)=[0 0 0 0];
%   
%   out=ppval(pp,xx);

  out=pchip(x(mask~=0),y(mask~=0),xx);
end

