function [bgm,bgy,startind,endind] = find_bg(m,y,nsteps,ndatapoints,startmass,endmass)
%find_bg calculates a list of bgr values for a certain number of data points i.e. masses
%   for input parmeters     m (list of masses from raw data, massaxis) 
%                           y (list of yields from raw data, signal)
%                           nsteps (= ndiv, intervall size for cutting the spec)
%                           ndatapoints (= percent, amount of data points used for bgr correction)
%                           startmass (taken from e_startmass), endmass (taken from e_endmass)
%   the function calculates a list of bgr values belonging to certain mass values.
%   The output values are   bgm (list of masses)
%                           bgy (list of background yields)
%                           startind (index of lowest mass that will be considered)
%                           endind (inex of highest mass that will be considered)

% find indices of start and end mass chosen in e_startmass and e_endmass
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

l=length(ys);

% calculate number of points that are used to calculate bgr
step=l/nsteps;
nminima=round(step*ndatapoints/100);

bgm=[];
bgy=[];
for i=1:nsteps;
    signal=y(floor((i-1)*step)+1:floor(i*step)); % cut spectrum in pieces of size (step) to select min masses
    [minmasses,ix]=sort(signal);
    minmasses=minmasses(1:nminima);              % only take certain amount (percent), lower part of all masses
    ix=ix(1:nminima);
    bgm(i)=m(floor(((2*i-1)*step)/2)+1);         % mean mass 
    %bgm(i)=m(round(mean(ix))); %mean mass
    bgy(i)=mean(minmasses);                      % average bgr for certain mass
    
%     bgm=[bgm,m(ix+floor((i-1)*step)+startvalue-1)];
%     bgy=[bgy,minmasses];
end

%p=polyfit(bgm,bgy,polydegree);

%plot(bgm,bgy);hold on;

% bgydata=zeros(1,length(m));
% for i=0:polydegree
%     bgydata=bgydata+p(i+1)*m.^(polydegree-i);
% end

% massout=m;
% signalout=y;

% just in case sort masses again and yields accordingly
% [bgm,ix]=sort(bgm);
% bgy=bgy(ix);

startind=ix1;
endind=ix2;
%bgpolynomout=p;

end

