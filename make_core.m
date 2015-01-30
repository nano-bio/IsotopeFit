function out = make_core(file,s_pt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

shape=load(file);


% find maximum and FWHM. set x- axis accordingly
% max --> x=0 / FWHM --> x=+-0.5
[maxval,maxidx]=max(shape(:,2));
FWHMidx=find(shape(:,2)>=maxval/2,1);

massaxis=(((1:size(shape,1))-maxidx)/(maxidx-FWHMidx))/2;

startidx=find(shape(:,2)>maxval/1000,1);
endidx=size(shape,1)-find(shape(end:-1:1,2)>maxval/1000,1);

shape=shape(startidx:endidx,:);
massaxis=massaxis(startidx:endidx);

% area has to be 1
shape(:,2)=shape(:,2)/sum(shape(1:end-1,2).*diff(massaxis)');
shape(:,1)=massaxis';

%out=spline(shape(:,1),[0;shape(:,2);0]);

%out=spline(shape(startidx:endidx,1),[0;0;shape(startidx+1:endidx-1,2);0;0]);

%out.coefs(1,:)=zeros(1,size(out.coefs,2));
%out.coefs(end,:)=zeros(1,size(out.coefs,2));

sind=round((0:s_pt-1)/(s_pt-1)*(size(shape,1)-10)+9);
sind=[sind(1),diff(sind)];

%cumsum([sind(1) diff(sind)])

%find best spline interpolation with genetic algorithm


% Aineq=zeros(s_pt-1,s_pt);
% Aineq(:,1:end-1)=eye(s_pt-1);
% Aineq(:,2:end)=Aineq(:,2:end)-eye(s_pt-1)
% 
% bineq=repmat(-1,s_pt-1,1);

%Aineq*sind'

problem.Aineq=ones(1,s_pt);
problem.bineq=size(shape,1)-1;

problem.lb=ones(1,s_pt)*2; %lower bound
problem.ub=ones(1,s_pt)*size(shape,1)-1; % upper bound

%problem.intcon=1:s_pt; %restrict all values of x to integers



% ============== GENETIC ALGORITHM =========================
fprintf('Peak shape optimization with genetic algorithm...\n PLEASE WAIT...\n');

problem.nvars=s_pt;
problem.fitnessfcn=@(x) msdspline(x,shape);
problem.options = gaoptimset('Generations', 10000,...
                     'PopulationSize',100,...
                     'EliteCount',round(s_pt/5),...
                     'Display','iter');
ind=ga(problem);

fprintf('DONE.\n');

% =============== Patternsearch ==================
% problem.objective=@(x) msdspline(x,shape);
% problem.x0=[sind(1) diff(sind)];
% problem.options=psoptimset('Display','iter',...
%                            'InitialMeshSize',500);
% ind=patternsearch(problem);


% ind=round([1,cumsum(ind),size(shape,1)])
% sind=[1,sind,size(shape,1)]


%ones(1,s_pt)
%ind=round(ind);

[x,y]=splinevector(sind,shape);
ispline=interpfcn(x,y);
%out.coefs(1,:)=zeros(1,size(out.coefs,2));
%out.coefs(end,:)=zeros(1,size(out.coefs,2));

[x,y]=splinevector(ind,shape);
out=interpfcn(x,y);
%ispline.coefs(1,:)=zeros(1,size(ispline.coefs,2));
%ispline.coefs(end,:)=zeros(1,size(ispline.coefs,2));

hold off
plot(shape(:,1),shape(:,2),shape(:,1),ppval(ispline,shape(:,1)),shape(:,1),ppval(out,shape(:,1)));
hold on

plot(x,y,'r.');

end

function [xout,yout]=splinevector(ind,shape)
  n=1; %points to add at end and beginning
  xout=[shape(1,1)-(n:-1:0)';shape(round(cumsum(ind)),1);shape(end,1)+(0:n)'];
  yout=[zeros(n+1,1);shape(round(cumsum(ind)),2);zeros(n+1,1)]; %n+1 for initial and final slope = 0
end

function out=msdspline(ind,shape)
    %ind=ind+[0, diff(ind)==0];
    %cumsum(ind)
    
%     x=shape(round([1,cumsum(ind),size(shape,1)]),1);
%     y=shape(round([1,cumsum(ind),size(shape,1)]),2);
%     y(1)=0;
%     y(end)=0;

    [x,y]=splinevector(ind,shape);
  
    s=interpfcn(x,y);
    %s.coefs(1,:)=zeros(1,size(s.coefs,2));
    %s.coefs(end,:)=zeros(1,size(s.coefs,2));

    %out=sum(((shape(:,2)-ppval(s,shape(:,1)))./(shape(:,2))).^2)*1e6;
    out=sum(((shape(:,2)-ppval(s,shape(:,1)))).^2)*1e6;
end

function out=interpfcn(x,y)
  out=pchip(x,y);
  %out=spline(x,y);
end

