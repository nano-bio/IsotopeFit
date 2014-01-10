function out = mass2ind(massaxis,mass)
%out = mass2ind(massaxis,mass)
%finds nearest mass in massaxis and returns index

if massaxis(end)>=mass;
    out=find(massaxis>=mass,1);
else
    out=length(massaxis);
end


end

