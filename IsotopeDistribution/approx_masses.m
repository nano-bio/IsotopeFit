function out = approx_masses(distribution,minmassdistance)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

mass_dist=double(distribution(:,1));
p_dist=double(distribution(:,2));

[mass_dist, ix]=sort(mass_dist);
p_dist=p_dist(ix);

massdiff=diff(mass_dist);
[a,ix]=min(massdiff);


while a<=minmassdistance
    d=combine_peaks([mass_dist p_dist],ix);
    mass_dist=d(:,1);
    p_dist=d(:,2);
    if ix==length(massdiff)
        massdiff=massdiff(1:end-1);
    else
        %massdiff=diff(mass_dist);
        massdiff=[massdiff(1:ix-1);massdiff(ix+1:end)];
        massdiff(ix)=mass_dist(ix+1)-mass_dist(ix);
    end
    [a,ix]=min(massdiff);
end





out=[mass_dist,p_dist];

end

