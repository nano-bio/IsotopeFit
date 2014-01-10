function out = multinomialcount(n,s)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%s=length(p) Anzahl der Wahrscheinlichkeiten = Stellen der Multinomialverteilung
%n... Anzahl der durchgeführten zufallsexperimente


if (s==1)||(n==0) 
    out=repmat(n,1,s); 
else
    temp=zeros(nelements(n,s),s);
    pos=1;
    for i=0:n
        nel=nelements(n-i,s-1);
        temp(pos:pos+nel-1,:)=[repmat(i,nel,1),multinomialcount(n-i,s-1)];
        pos=pos+nel;
    end
    out=temp;
end;



end

