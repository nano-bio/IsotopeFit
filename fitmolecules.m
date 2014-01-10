function out = fitmoleculelist(datafile,folder,rangeth,startvalues,rangetofit)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

addpath('DERIVESTsuite');
addpath('FMINSEARCHBND');


choice = questdlg('Do you want to perform a background correction?', ...
	'Background correction', ...
	'Yes','No','Yes');
% Handle response
drawnow;
switch choice
    case 'Yes'
        [massaxis spec_measured]=bg_correction(datafile);
    case 'No'
        A=load(datafile);
        
        massaxis=A(:,1)';
        spec_measured=A(:,2)';
end

moleculelist=foldertolist(folder);
%startvalues=[repmat(startvalues(1),1,length(moleculelist)) startvalues(2) startvalues(3)]
if length(startvalues)-2~=length(moleculelist)
    fprintf('ERROR: Check number of starting values!!\n');
    return;
end

molecules=loadmolecules(folder,moleculelist,massaxis,rangeth,startvalues);


%find massranges and involved molecules
rangecount=1;
ranges{1}.minind=molecules{1}.minind;
ranges{1}.maxind=molecules{1}.maxind;
ranges{1}.minmass=molecules{1}.minmass;
ranges{1}.maxmass=molecules{1}.maxmass;
ranges{1}.molecules{1}=molecules{1};

for i=2:length(molecules)
    if molecules{i}.minmass<=ranges{rangecount}.maxmass %molecule massrange ovelaps
        ranges{rangecount}.maxind=molecules{i}.maxind;
        ranges{rangecount}.maxmass=molecules{i}.maxmass;
        ranges{rangecount}.molecules{end+1}=molecules{i};
    else %new massrange
        rangecount=rangecount+1;
        ranges{rangecount}.minind=molecules{i}.minind;
        ranges{rangecount}.maxind=molecules{i}.maxind;
        ranges{rangecount}.minmass=molecules{i}.minmass;
        ranges{rangecount}.maxmass=molecules{i}.maxmass;
        ranges{rangecount}.molecules{1}=molecules{i};
    end
end

fprintf('\nFound %i massranges. start fitting...\n',rangecount);

if nargin==5
    startrange=rangetofit;
    endrange=rangetofit;
else
    startrange=1;
    endrange=rangecount;
end

for i=startrange:endrange
    drawnow;
    nmolecules=length(ranges{i}.molecules);
    parameters=zeros(1,nmolecules+2);
    fprintf('Fitting massrange %i (%5.1f - %5.1f): %i molecules\n',i, ranges{i}.minmass,ranges{i}.maxmass,nmolecules);
    for j=1:nmolecules
        parameters(j)=ranges{i}.molecules{j}.area;
    end
    parameters(nmolecules+1)=startvalues(end-1); %resolution
    parameters(nmolecules+2)=startvalues(end); %x-offset

    %fitparam=fminsearch(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),parameters,optimset('MaxFunEvals',10000,'MaxIter',10000));
    fitparam=fminsearchbnd(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),parameters,[repmat(0,1,length(parameters)-2),parameters(end-1)-parameters(end-1)*0.5, -0.5],[parameters(1:end-2)*10000,parameters(end-1)+parameters(end-1)*0.5, 0.5],optimset('MaxFunEvals',5000,'MaxIter',5000));
    
    fprintf('Error estimation...\n');
    %error estimation
    dof=ranges{i}.maxind-ranges{i}.minind-2;
    sdrq = (msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,fitparam))/dof;
    J = jacobianest(@(x) multispec(massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),fitparam);
    sigma = sdrq*inv(J'*J);
    %sigma = b/(J'*J);
    
    stderr = sqrt(diag(sigma))';
    
%     %std error estimation
%     [h, err]=hessian(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),fitparam);
%     stderr=diag(err)';
%     err(1:end-1)
% 
% %     [fitparam,fval,exitflag,output,grad,hessian]=fminunc(@(x) msd(spec_measured(ranges{i}.minind:ranges{i}.maxind),massaxis(ranges{i}.minind:ranges{i}.maxind),ranges{i}.molecules,x),parameters,optimset('MaxFunEvals',10000,'MaxIter',10000));
% %     
% %     %std error estimation
% %     cov=inv(hessian);
% %     stderr=sqrt(diag(cov)');
% %     stderr
    
    for j=1:nmolecules
        ranges{i}.molecules{j}.area=fitparam(j); %read out fitted areas for every molecule
        ranges{i}.molecules{j}.areaerror=stderr(j); %read out fitted areas for every molecule
    end
    ranges{i}.massoffset=fitparam(end);
    ranges{i}.resolution=fitparam(end-1);
    ranges{i}.massoffseterror=stderr(end);
    ranges{i}.resolutionerror=stderr(end-1);
end
fprintf('Done.\n')
%plot(massaxis,spec_measured,massaxis,multispec(massaxis,molecules,out));


subplot(2,2,1);
plot(massaxis,spec_measured,'Color',[0.7 0.7 0.7]);
hold on;
plot(massaxis,multispecranges(massaxis,ranges(startrange:endrange)),'Color',[0 0 0],'LineWidth',1);
hold off;

subplot(2,2,2);
plotmolecules(ranges(startrange:endrange));

subplot(2,2,3);
plotmassoffset(ranges(startrange:endrange));

subplot(2,2,4);
plotresolution(ranges(startrange:endrange));


fprintf('\n--------------------------------------------------------\n');
fprintf('Found mass-offsets and resolutions for different ranges:\n');
fprintf('Range\t Mass-offset\t Resolution (FWHM) \n');
for i=startrange:endrange;
    fprintf('%i \t %e+-%e \t %e+-%e \n',i,ranges{i}.massoffset,ranges{i}.massoffseterror,ranges{i}.resolution,ranges{i}.resolutionerror);
end

write_ranges(ranges,'out.txt');
write_startvalues(ranges,'startvalues.txt');

out=ranges;
end

