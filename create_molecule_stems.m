function out = create_molecule_stems(molecules,massaxis)
% out = create_molecule_stems(molecules,massaxis)
% creates dirac comb - like data with areas and masses for given set of
% molecules

out=zeros(1,length(massaxis));
h=waitbar(0,'Converting molecule structure...');
for i=1:length(molecules)
    for j=1:size(molecules(i).peakdata,1)
        ind=mass2ind(massaxis,molecules(i).peakdata(j,1));
        if (ind>1)&&(ind<length(massaxis))
            out(ind)=out(ind)+molecules(i).area*molecules(i).peakdata(j,2);
        end
    end
    if mod(i,10)==0,waitbar(i/length(molecules));end;
end
close(h);

end

