function out = atomic_distribution(element,n,minmassdistance,th)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

P=mfilename('fullpath');
P=P(1:end-19); %cut away atomic_distribution
 d=renorm(load([P 'Atoms' filesep element '.txt'])); %load isotope table
 
% d(:,2)=d(:,2)/(sum(d(:,2)));
 d_end=d;


for i=1:n-1
    d_end=convolute(d_end,d);
    d_end=approx_masses(d_end,minmassdistance);
    d_end=approx_p(d_end,th);
end


out=d_end;

%plot(mass_dist,p_dist,'xk');
%plot(dist_approx(:,1),dist_approx(:,2),'xk');

end

