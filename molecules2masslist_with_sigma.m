function [minmasslist,maxmasslist] = molecules2masslist_with_sigma(molecules,calibration,searchrange)
%molecules2masslist_with_sigma(molecules,calibration,searchrange)
%   same as molecules2masslist with +-searchrange*sigma borders

[minmasslist,maxmasslist] = molecules2masslist(molecules);

minmasslist=minmasslist-searchrange*sigmabycalibration(calibration,minmasslist);
maxmasslist=maxmasslist+searchrange*sigmabycalibration(calibration,maxmasslist);

end

