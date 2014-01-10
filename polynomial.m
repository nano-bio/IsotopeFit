function out=polynomial(coefficients,mass)
%resolution is given by n-th order polynome and massdependent

n=length(coefficients);
out=0;
for i=1:n
    out=out+coefficients(i).*(mass.^(n-i));
end

end

