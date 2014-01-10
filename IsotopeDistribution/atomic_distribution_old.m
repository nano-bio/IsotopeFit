function out = atomic_distribution(element,n)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

A=load(['Atoms\' element '.txt']); %load isotope table

masses=A(:,1)';
p_isotopes=A(:,2)';

p_isotopes=p_isotopes/(sum(p_isotopes));

n_dist=multinomialcount(n,length(p_isotopes));
p_dist=mnpdf(n_dist,p_isotopes);

mass_dist=sum(n_dist.*repmat(masses,size(n_dist,1),1),2);

%sort masses
%[mass_dist,ix]=sort(mass_dist);
%p_dist=p_dist(ix);

%dist_approx=approx_masses([mass_dist p_dist],massdivision);
%dist_approx=approx_p(dist_approx,th);

%out=(dist_approx);

out=[mass_dist p_dist];

%plot(mass_dist,p_dist,'xk');
%plot(dist_approx(:,1),dist_approx(:,2),'xk');

end

