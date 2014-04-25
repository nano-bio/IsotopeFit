function out=sigmabycalibration(calibration,massaxis)

resolution=getcalibrationdata(calibration.comlist,calibration.resolutionlist,calibration.resolutionparam,calibration.resolutionmethode,massaxis);
out=massaxis./resolution*(1/(2*sqrt(2*log(2))));

end

