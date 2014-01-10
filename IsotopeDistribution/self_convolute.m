function out = self_convolute(d,n,minmassdistance,th)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

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

