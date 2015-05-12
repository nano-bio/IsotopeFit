function out = sum_formula2cid(string)
%converts a sum formula to a cluster id (cid)
%the cluster id cid is a vector of length 118, containing the number of
%atoms of each element
%e.g. H20 -> [2 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 ...]

elements={'H' 'He' 'Li' 'Be' 'B' 'C' 'N' 'O' 'F' 'Ne' 'Na' 'Mg' 'Al'...
          'Si' 'P' 'S' 'Cl' 'Ar' 'K' 'Ca' 'Sc' 'Ti' 'V' 'Cr' 'Mn' 'Fe'...
          'Co' 'Ni' 'Cu' 'Zn' 'Ga' 'Ge' 'As' 'Se' 'Br' 'Kr' 'Rb' 'Sr'...
          'Y' 'Zr' 'Nb' 'Mo' 'Tc' 'Ru' 'Rh' 'Pd' 'Ag' 'Cd' 'In' 'Sn'...
          'Sb' 'Te' 'I' 'Xe' 'Cs' 'Ba' 'La' 'Ce' 'Pr' 'Nd' 'Pm' 'Sm'...
          'Eu' 'Gd' 'Tb' 'Dy' 'Ho' 'Er' 'Tm' 'Yb' 'Lu' 'Hf' 'Ta' 'W'...
          'Re' 'Os' 'Ir' 'Pt' 'Au' 'Hg' 'Tl' 'Pb' 'Bi' 'Po' 'At' 'Rn'...
          'Fr' 'Ra' 'Ac' 'Th' 'Pa' 'U' 'Np' 'Pu' 'Am' 'Cm' 'Bk' 'Cf'...
          'Es' 'Fm' 'Md' 'No' 'Lr' 'Rf' 'Db' 'Sg' 'Bh' 'Hs' 'Mt' 'Ds'...
          'Rg' 'Uub' 'Uut' 'Uuq' 'Uup' 'Uuh' 'Uus' 'Uuo'};

out=uint16(zeros(1,118));
      
i=1;

l=length(string);
string(l+1)=' '; %something. only needs to be accessable...

while i<=l %parse string
    if (string(i)>='A')&&(string(i)<='Z')
        %new element
        startpos=i;
        i=i+1;
        while (string(i)>='a')&&(string(i)<='z')&&(i<=l), i=i+1; end;
        substring=string(startpos:i-1); %the name of the element
        startpos=i;
        while (string(i)>='0')&&(string(i)<='9')&&(i<=l), i=i+1; end;
        if startpos==i %no number found
            n=1;
        else
            n=str2double(string(startpos:i-1));
        end
        
        ind=find(ismember(elements,substring));
        out(ind)=out(ind)+n;
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
                nbraces=nbraces+1;
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
        
        out=out+sum_formula2cid(substring)*n;
    end
end


end

