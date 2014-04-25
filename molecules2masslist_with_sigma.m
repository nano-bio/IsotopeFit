function [minmasslist,maxmasslist] = molecules2masslist_with_sigma(molecules,calibration,searchrange)
%molecules2masslist_with_sigma(molecules,calibration,searchrange)
%   same as molecules2masslist with +-searchrange*sigma borders

minmasslist=[molecules.minmass]-searchrange*sigmabycalibration(calibration,[molecules.minmass]);
maxmasslist=[molecules.maxmass]+searchrange*sigmabycalibration(calibration,[molecules.maxmass]);

end

