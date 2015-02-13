function out = multispec(molecules,resolutionaxis,massoffsetaxis,massaxis,shape)
%out= multispec(molecules,resolution,massoffset,massaxis)
%   calculates isotopic pattern for molecules in list
%   uses area stored in molecules structure
%   DONT use this for fitting!

spec_calc=zeros(1,length(massaxis));

show_waitbar = 0;

tstart=tic;

for i=1:length(molecules)
    
    spec_calc=spec_calc+pattern(molecules(i),molecules(i).area,resolutionaxis,massoffsetaxis,massaxis,shape);
    if show_waitbar==1
        waitbar(i/length(molecules));
    end
    
    if toc(tstart)>0.5 && show_waitbar==0
        h = waitbar(0,'Please wait...');
        show_waitbar=1;
    end
end


if show_waitbar == 1
    close(h);
end

out=spec_calc;

end

