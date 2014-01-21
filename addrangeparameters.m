function out = addrangeparameters(ranges,comlist,massoffsetlist,resolutionlist)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


    for i=1:length(ranges)
        %     ranges{i}.massoffset=polynomial(massoffsetpolynom,ranges{i}.com);
        %     ranges{i}.resolution=polynomial(resolutionpolynom,ranges{i}.com);
        [ranges{i}.massoffset, ranges{i}.resolution]=parameterinterpolation(comlist,massoffsetlist,resolutionlist,ranges{i}.com)
       
    end
    
out=ranges;

end

