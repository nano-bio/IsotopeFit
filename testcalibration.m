folder='PET\C60test\';
datafile='PET\c60.txt';

%Load peakdata from ASCII file
peakdata=load(datafile);

%Load molecules in Structure
moleculelist=foldertolist(folder);
molecules=loadmolecules(folder,moleculelist,peakdata);

molecules{2}


calibrate(peakdata,molecules);
