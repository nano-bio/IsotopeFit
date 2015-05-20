function batch_fit(folder)
% batch_fit(folder)
%  searches for *.ifd files in [folder] and fits the molecule data to the
%  spectrum

% Here we define the points which are used for fitting. We use all the
% points that are in the range of +- searchrange*sigma of a certain peak
searchrange=1;


%Search for ifd files and store the filenames in filelist:
fprintf('Searching for *.ifd files...\n')

filelist={};

a=dir(folder);
for i=1:length(a)
    if ~a(i).isdir
        [~,~,ext] = fileparts(a(i).name);
        if strcmp(ext,'.ifd')
            filelist{end+1}=a(i).name;
            fprintf('%s\n',a(i).name)
        end
    end
end

fprintf('\nFound %i file(s)\n\nStart fitting...\n',length(filelist));

for fnum=1:length(filelist) %loop through every file
    t_tot_start=tic; %read out system time for benchmark
    data={};
    fprintf('\n\n=======================================================\n');
    fprintf('Loading %s...',filelist{fnum})
    
    %load the data stored in the ifd - file:
    data=load_ifd(filelist{fnum},folder,data);
    %load(fullfile(folder,filelist{fnum}),'-mat');
    fprintf('done.\n')
      
    l=size(data.peakdata,1); %number of lines = number of datapoints in the spectrum
    n_mol=length(data.molecules);%number of molecules
    fprintf('Found %i molecules.\n',n_mol);
    
    massaxis=double(data.peakdata(:,1));
    signal=double(data.peakdata(:,2));
        
    %construct a piecewise polynomial for faster resolution calculation
    switch lower(data.calibration.resolutionmethode)
        case 'flat'
            % constant function = piecewise polynomial of order 1 and only
            % one parameter
            r_pp=mkpp([0 Inf],data.calibration.resolutionparam);
        case 'polynomial'
            % one piece, but arbitrary order of the polynomial
            p=polyfit(data.calibration.comlist,data.calibration.resolutionlist,data.calibration.resolutionparam);
            r_pp=mkpp([0 Inf],p);
        % spline and pchip are already in pp definition:
        case 'spline'
            r_pp=spline(data.calibration.comlist,data.calibration.resolutionlist);
        case 'pchip'
            r_pp=pchip(data.calibration.comlist,data.calibration.resolutionlist);
    end
    
    fprintf('\nCreating design matrix... ')
    M=sparse(l,n_mol);
    
    fitmask=false(1,l); %to eliminate datatpoints that are not covered with peaks
    fwhmrange=0.5;
    
    
    percent=0.1;
    times=zeros(1,4); %bench mark times for peakshape calculation, index finding, fitmask finding and Matrix addition
    
    for i=1:n_mol %columns
        if i/n_mol>=percent
            fprintf('%i.',round(100*percent));
            percent=percent+0.1;
        end
        for j=1:size(data.molecules(i).peakdata,1) %rows: go through every isotope peak
            tic;
            %isotope parameters:
            mass=data.molecules(i).peakdata(j,1);
            area=data.molecules(i).peakdata(j,2);
            %R=resolutionbycalibration(data.calibration,mass);
            R=ppval(r_pp,mass);
            
            %recalculate peakshape
            peakshape=peak_width_adaption(data.calibration.shape,mass/R,1);
            
            peakshape.breaks=peakshape.breaks+mass;
            times(1)=times(1)+toc;
            
            % for faster peakshape calculation, find the massrange of the
            % peak
            tic
            ind=find(peakshape.breaks(1)<massaxis & peakshape.breaks(end)>massaxis);
            times(2)=times(2)+toc;
            tic
            
            % for fitting, we use only points that are in a certain range
            % around the peak: we use a "fitmask" which has an entry for
            % every data point whether this point is used or not
            fitmask((mass-searchrange*fwhmrange*mass/R<massaxis) & (mass+searchrange*fwhmrange*mass/R>massaxis))=true;
            times(3)=times(3)+toc;
            tic
            
            %add the peak to the design matrix
            M=M+sparse(ind,ones(size(ind))*i,area*double(ppval(peakshape,massaxis(ind))),l,n_mol);
            times(4)=times(4)+toc;
        end
    end
    fprintf('done.\n')
    fprintf('TIMES:\npeakshape calculation:\t%fs\nindex finding:\t%fs\nfitmask finding:\t%fs\nMatrix addition:\t%fs\n',times)
    
    % use only the points in the fitmask:
    M=M(fitmask,:);
    signal=signal(fitmask);
    
    tic
    fprintf('\nFitting... ')
    A=lsqnonneg(M,signal); %least squares whit non negative solutions
    %A=M\signal;
    %A=lsqlin(M,signal,[],[],[],[],zeros(1,n_mol));
    fprintf('done.\n')
    toc
    
    fprintf('\nError estimation... ')
    %Here we have to compute inv(M'*M) which may be inaccurate in some
    %cases. we use qr factorization.
    tic

    R=qr(M,0); % Q is orthogonal (Q'Q=QQ'=1), R is upper triangular, QR=M

    s_calc=M*A;
    S=R\speye(n_mol); %S=inv(R)=R\eye  --> then inv(M'*M)=S*S'
    
    %free memory:
    clear R;
       
    l=sum(fitmask);

    S_err=sparse(1:l,1:l,(signal-s_calc).^2,l,l);

    A_err=sqrt(diag(S*S'*M'*S_err*M*S*S'));
    
    % for large matrices that dont fit into RAM:
    % A_err=sqrt(diag_eco({S,S',M',S_err,M,S,S'}));

    
    fprintf('done.\n')
    toc;
    
    fprintf('\nWrite data to ifd file... ');
    for i=1:n_mol
        data.molecules(i).area=A(i);
        data.molecules(i).areaerror=A_err(i);
    end
    %data is now fitted
    data.status.guistatusvector(7)=1;
    
    save(fullfile(folder,filelist{fnum}),'data');
    
    fprintf('done.\n')
    fprintf('Total calculation time: %fs\n',toc(t_tot_start))
end

end

