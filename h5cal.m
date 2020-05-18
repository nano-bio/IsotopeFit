function ma = h5cal(datafile)
    mcf = h5readatt(datafile, '/FullSpectra', 'MassCalibration Function');
    samples = h5readatt(datafile, '/', 'NbrSamples');

    % find all parameters
    pattern = 'p[0-9]+';
    pnames = regexp(mcf, pattern, 'match');

    % convert each to a symbolic variable
    for i = 1:length(pnames)
        % evalc is basically the same as eval, but it shuts the fuck up. c
        % stands for "capture" so we capture it to a random variable
        silence = evalc([pnames{i} ' = sym(pnames{i})']);
        
        % assume they are real
        eval(['assume(' pnames{i} ', ''real'')'])
    end
    syms symi m;

    % assume indices and masses to be larger than zero
    assume(m > 0);
    assume(symi > 0);
    assume(m, 'real');
    assume(symi, 'integer');

    % FUN FACT: the last character that comes out of the h5 file looks like a
    % space (ASCII 32), but it isn't! It's a NUL instead (ASCII 0). Solve
    % doesn't like that kind of trickery, so we have to remove it (strtrim
    % doesn't work - doesn't trim ASCII 0).
    %mcf = mcf(1:end-1);
    mcf = strcat('symi',mcf(2:end-1));

    % solve for m; we only want real solutions
    if ~verLessThan('matlab', '9.3') % for matlab 2017b and newer
        warning('off','symbolic:solve:SolutionsDependOnConditions')
        reverse_mcf = solve(str2sym(mcf), m, 'real', true,'ReturnConditions',false);
        warning('on','symbolic:solve:SolutionsDependOnConditions')
    else
        reverse_mcf = solve(mcf, m, 'real', true);
    end
    %a=0.0;

    % assign numerical values to the parameters (symbols not needed any more)
    for n = 1:length(pnames)
        p{n} = h5readatt(datafile, '/FullSpectra', ['MassCalibration ' pnames{n}]);
        silence = evalc([pnames{n} ' = ' num2str(p{n}, '%10.10f')]);
    end
    
    % create linspace of indices
    symi = 1:double(samples);
    % evaluate the reversed calibration function to retrieve massaxis
    ma = eval(reverse_mcf);
    % apparantely in some cases this functions evaluates to some complex
    % numbers (despite the fact that a real solution is available). to make
    % sure not to produce any errors we take the absolute value.
    ma = abs(ma);
    % transpose
    ma = ma';
end