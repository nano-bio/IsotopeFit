function out = molecule_distribution(atoms,natoms,massdivision,th)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

if length(atoms)>2
    d1=atomic_distribution(atoms{1},natoms(1));
    d1=approx_p(d1,th);
    if massdivision~=0, d1=approx_masses(d1,massdivision); end;
    out=convolute(d1,molecule_distribution(atoms(2:end),natoms(2:end),massdivision,th));
elseif length(atoms)==2
    d1=atomic_distribution(atoms{1},natoms(1));
    d1=approx_p(d1,th);
    if massdivision~=0, d1=approx_masses(d1,massdivision); end;
    d2=atomic_distribution(atoms{2},natoms(2));
    d2=approx_p(d2,th);
    if massdivision~=0, d2=approx_masses(d2,massdivision); end;
    d=convolute(d1,d2);
    d=approx_p(d,th);
    if massdivision~=0, d=approx_masses(d,massdivision); end;
    out=d;
else
    d1=atomic_distribution(atoms{1},natoms(1));
    d1=approx_p(d1,th);
    if massdivision~=0, d1=approx_masses(d1,massdivision); end;
    out=d1;
end

