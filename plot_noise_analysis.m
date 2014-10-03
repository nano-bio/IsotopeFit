function plot_noise_analysis(file,column,precision)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

A=load(file);
xd=A(:,column);
yd=A(:,1);

[x,y]=meshgrid([min(xd):(max(xd)-min(xd))/precision:max(xd)],[min(yd):(max(yd)-min(yd))/precision:max(yd)]);

mindist=zeros(size(x));
% for i=1:size(x,1)
%     fprintf('line %i/%i\n',i,size(x,1));
%     for j=1:size(x,2)
%         mindist(i,j)=max(1./((50*(xd-x(i,j))).^2+(yd-y(i,j)).^2));
%     end
% end

mindist=sqrt(mindist);
th=0.5;
mindist(mindist>th)=th;

%pcolor(y,x,mindist);
%pcolor(x);
plot(yd,xd,'k.');
xlabel('Noise to Signal Ratio');
ylabel('Fitted Abundance');

shading flat;

end

