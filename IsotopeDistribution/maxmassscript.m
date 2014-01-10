for i=1:10
    d=parse_molecule(['(C60)' num2str(i)],1e-2,1e-6);
    [~,ix]=max(d(:,2));
    fprintf('%i\t%e\n',i,d(ix,1));
end