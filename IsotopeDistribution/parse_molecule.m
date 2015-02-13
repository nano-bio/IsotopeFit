function out = parse_molecule(string,minmassdistance,th)
%parse_molecule Create isotope pattern from molecule

i=1;

distributions={};
distcount=1;

l=length(string);
string(l+1)=' '; %something. only needs to be accessable...

while i<=l %parse string
    if (string(i)>='A')&&(string(i)<='Z')
        startpos=i;
        i=i+1;
        while (string(i)>='a')&&(string(i)<='z')&&(i<=l), i=i+1; end;
        substring=string(startpos:i-1);
        startpos=i;
        while (string(i)>='0')&&(string(i)<='9')&&(i<=l), i=i+1; end;
        if startpos==i %no number found
            n=1;
        else
            n=str2double(string(startpos:i-1));
        end
        %distributions{distcount}=atomic_distribution_old(substring,n);
        distributions{distcount}=atomic_distribution(substring,n,minmassdistance,th);
        distcount=distcount+1;
    end
    if string(i)=='('
        nbraces=1;
        startpos=i;
        while nbraces>0
            i=i+1;
            if string(i)==')'
                nbraces=nbraces-1;
            end
            if string(i)=='('
                nbraces=nbraces-1;
            end
        end
        substring=string(startpos+1:i-1);
        i=i+1;
        startpos=i;
        while (string(i)>='0')&&(string(i)<='9')&&(i<=l), i=i+1; end;
        if startpos==i %no number found
            n=1;
        else
            n=str2double(string(startpos:i-1));
        end
        
        distributions{distcount}=self_convolute(parse_molecule(substring,minmassdistance,th),n,minmassdistance,th);
        distcount=distcount+1;
    end
end

%convolute
d_end=distributions{1};
for i=2:distcount-1
    d_end=convolute(d_end,distributions{i});
    d_end=approx_masses(d_end,minmassdistance);
    d_end=approx_p(d_end,th);
end
out=d_end;

end

