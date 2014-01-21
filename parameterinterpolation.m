function [massoffset, resolution] = parameterinterpolation(comlist,massoffsetlist,resolutionlist,com)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if isempty(comlist)
    %standardvalues
    massoffset=0;
    resolution=3000;
else
    if (com>=comlist(1))&&(com<=comlist(end))
        massoffset=pchipmod(comlist,massoffsetlist,com);
        resolution=pchipmod(comlist,resolutionlist,com);
    else
        massoffset=mean(massoffsetlist);
        resolution=mean(resolutionlist);
    end
end


end

