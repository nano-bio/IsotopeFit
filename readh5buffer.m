function buffercontent = readh5buffer(fn, writenumber, buffernumber)
    % returns the contents of a specific buffer
    
    % we don't need to check whether the file exists, because the next
    % function does that anyway
    timebins = getnumberofinstancesinh5(fn, 'timebins');
    buffercontent = zeros(timebins, 1);
    % reads the a specific buffer from a h5 file 
    data = h5read(fn, '/FullSpectra/TofData', [1 1 buffernumber writenumber], [timebins 1 1 1]);
    buffercontent(:, 1) = sum(data, 3);
    buffercontent = buffercontent';
    return;
end