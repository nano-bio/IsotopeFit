%change directory to isotopedistribution folder
cd ('..');

%enter folder and filename.
% saves molecules to IsotopeFit\IsotopeDistribution\folder\file.ifm
folder='folder_for_ifm_file';
file='molecules';

% DONT CARE ABOUT THE FOLLOWING LINES
% -------------------------------------------------------
% If file exists, delete it and generate a new one
if exist([folder,'\',filename,'.ifm'])==2
    fprintf('Old File removed.\n');
    delete([folder,'\',filename,'.ifm']);
end
% -------------------------------------------------------
% CARE AGAIN

%set threshold for isotope abundance
th=1e-3;
%set threshold for minimum peak distance
mapprox=1e-4;

%list of cluster numbers. this can be written directly into generate
%function
nC60=[1,2,4]; %[C60]1, [C60]2 and [C60]4
nCO2=[0:60]; %[CO2]n with n from 0 to 60

%-------------------------------------------  generate clusters:

% C60 with CO2 attached, normal and hydrogenated species (n(H)= 0 or 1):
generate_cluster_ifm(folder,file,{'C60' 'CO2' 'H'},{nC60 nCO2 [0 1]},mapprox,th);

% attach H20 to isolated CO2's:
generate_cluster_ifm(folder,file,{'CO2' 'H2O'},{nCO2 [0 1]},mapprox,th);

%doubly charged ions:
generate_cluster_ifm(folder,file,{'C60' 'CO2'},{nC60 nCO2},mapprox,th,{'C60++' 'CO2'},2);

%-------------------------------------------  generate clusters end


% for generation of single files, use generate_cluster function:
% --> i.e. generate_cluster_ifm(folder,{'C60' 'CO2' 'H'},{nC60 nCO2 [0 1]},mapprox,th); 
% no filename needed!
% but ifm files are recommended!