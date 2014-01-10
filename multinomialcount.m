function out = multinomialcount(n,s)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%s=length(p) Anzahl der Wahrscheinlichkeiten = Stellen der Multinomialverteilung
%n... Anzahl der durchgeführten zufallsexperimente

temp=zeros(1,s);
count=1;
if s==1
    out=n;
else
    while temp(1)<n
        if sum(temp(1:s-1))>n
            k=1;
            while(sum(temp(1:s-1)))>n
                temp(s-k)=0;
                k=k+1;
                temp(s-k)=temp(s-k)+1;
            end
        end
        temp(s)=n-sum(temp(1:s-1));
        out(count,:)=temp;
        count=count+1;
        temp(s-1)=temp(s-1)+1;
    end
    if s==2
        out(count,:)=[n 0];
    end
end




end

