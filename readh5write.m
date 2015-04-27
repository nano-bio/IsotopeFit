function writesum = readh5write(fn, writenumber)
    % calculates the sum over a given write in a h5 file
    
    buffers = getnumberofinstancesinh5(fn, 'buffers');
    timebins = getnumberofinstancesinh5(fn, 'timebins');
    writesum = zeros(timebins, 1);

    data = h5read(fn, '/FullSpectra/TofData', [1 1 1 writenumber], [timebins 1 buffers 1]);
    writesum(:, 1) = sum(data, 3);
    writesum = writesum';
    return;
end