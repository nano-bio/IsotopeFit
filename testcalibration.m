
addpath('DERIVESTsuite');
addpath('FMINSEARCHBND');

folder='PET\C60\';
datafile='PET\c60.txt';

%Load peakdata from ASCII file
peakdata=bg_correction(datafile);

%Load molecules in Structure
moleculelist=foldertolist(folder);
molecules=loadmolecules(folder,moleculelist,peakdata);

molecules{2}


calibrate(peakdata,molecules);
