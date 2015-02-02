function peakdataout=approxpeakdata(peakdata,samplerate)
    %this function resamples the peakdata with a given, equidistant
    %samplerate (i.e. 0.1 massunits)
    l=size(peakdata,1);

    %% massaxis needs to be smooth for resampling
    mass=spline(1:round(l/1000):l,peakdata(1:round(l/1000):l,1)',1:l);

   %% sometimes, the spectrum isnt incrasing at the begininng. cut out
   % this region
   ind=find(diff(mass)<=0);

   if ~isempty(ind)
       ind=ind(end)+1;
   else
       ind=1;
   end

   %% resampling
   mt=mass(ind):samplerate:mass(end);
   peakdataout=[mt',...
                double(interp1(mass(ind:end),peakdata(ind:end,2)',mt))'];
end