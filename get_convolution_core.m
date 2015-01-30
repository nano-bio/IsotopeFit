function [core,x] = get_convolution_core(peakdata,molecule_stems)
%[core,x] = get_convolution_core( input_args )
%   calculates convolution core and shifted x-values for given peakdata and
%   molecule_stems (create this with create_molecule_stems)

core=double(ifftshift(ifft(fft(peakdata(:,2)')./fft(molecule_stems))))';
x=double((((0:size(peakdata,1)-1)'/(size(peakdata,1)-1))-(0.5))*2*size(peakdata,1));

%mass units:
x=x*mean(diff(peakdata(:,1)));

end

