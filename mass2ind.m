function out = mass2ind(massaxis,mass)
%out = mass2ind(massaxis,mass)
%finds nearest mass in massaxis and returns index

[~,out]=min(abs(massaxis-mass));

end

