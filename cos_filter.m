function f=cos_filter(A,mus,mue,P,x)

% A=1;
% mus=1;
% mue=1.5;
% P=3;
% 
% x=-1:0.01:4;

%f=A*(1-cos(2*pi*(x+P/2-mus)/P));

[~, ix1]=min(abs(x-mus+P/2));
[~, ix2]=min(abs(x-mus));
[~, ix3]=min(abs(x-mue));
[~, ix4]=min(abs(x-mue-P/2));

f=zeros(1,length(x));

f(ix1:ix2)=A/2*(1-cos(2*pi*(x(ix1:ix2)+P/2-mus)/P));
f(ix2:ix3)=A;
f(ix3:ix4)=A/2*(1-cos(2*pi*(x(ix3:ix4)+P/2-mue)/P));

% 
% plot(x,f);
end