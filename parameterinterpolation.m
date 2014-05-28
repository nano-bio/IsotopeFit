function [massoffset, resolution] = parameterinterpolation(comlist,massoffsetlist,resolutionlist,com)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if isempty(comlist)
    %standardvalues
    massoffset=0;
    resolution=3000;
else
    if (com<=comlist(1)-0.1)
        massoffset=massoffsetlist(1);
        resolution=resolutionlist(1);
    elseif (com>=comlist(end)+0.1)
        massoffset=massoffsetlist(end);
        resolution=resolutionlist(end);
    else
        massoffset=pchipmod(comlist,massoffsetlist,com);
        resolution=pchipmod(comlist,resolutionlist,com);
    end
end


end

