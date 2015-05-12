function out=subtractbg(peakdata,bgcorrectiondata)
out=peakdata;
%out(:,2)=out(:,2)-polynomial(bgpolynom,peakdata(:,1));
if length(bgcorrectiondata.bgm)>1
    out(:,2)=out(:,2)-interp1(bgcorrectiondata.bgm',bgcorrectiondata.bgy',peakdata(:,1),'pchip','extrap');
end
end


