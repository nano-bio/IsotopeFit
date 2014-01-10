function out = approx_masses(distribution,massdivision)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

mass_dist=distribution(:,1)';
p_dist=distribution(:,2)';

massrange=1/massdivision;

actual_mass=min(mass_dist)-massrange/2;
maxmass=max(mass_dist);
peakcount=1;

while actual_mass<=maxmass
    masssum=0;
    psum=0;
    ix=find((mass_dist>=actual_mass)&(mass_dist<actual_mass+massrange));
    if ~isempty(ix)
        p_dist_approx(peakcount)=sum(p_dist(ix));
        mass_dist_approx(peakcount)=sum(mass_dist(ix).*p_dist(ix))/p_dist_approx(peakcount);
        peakcount=peakcount+1;
    end
    actual_mass=actual_mass+massrange;
end

out=[mass_dist_approx' p_dist_approx'];

end

