function out=subtractmassoffset(peakdata,calibration)
out=peakdata;
xaxis=min(peakdata(:,1)):0.01:max(peakdata(:,1));
mo=massoffsetbycalibration(calibration,xaxis);
%mo=massoffsetbycalibration(calibration,peakdata(:,1));

% maybe you think, that this would do the job:
% out(:,1)=out(:,1)-mo;
% BUT THINK ABOUT:
% you have to calculate the mass offset for the position of the
% SHIFTED spectrum. This requires the calculation of the INVERSE:
% mass_old = mass_new + mo(mass_new)
%          = A * mass_new
%                    with A = eye*[(mass_new+mo(mass_new))./mass_new]
% mass_new = inv(A) * mass_old
% A is diagonal -> yeah, you simply have to perform a pointwise
% division:

%out(:,1)=out(:,1).*(out(:,1)./(out(:,1)+mo));
yaxis=xaxis+mo;
out(:,1)=interp1(yaxis,xaxis,peakdata(:,1),'pchip','extrap');

%          for i=1:size(out,1);
%             ind=mass2ind(peakdata(:,1),peakdata(i,1)+mo(i));
%             out(i,2)=peakdata(ind,2);
%             if ~mod(i,1000)
%                 fprintf('%i/%i\n',i,size(out,1))
%             end
%          end
end