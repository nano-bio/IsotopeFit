function value = getnumberofinstancesinh5(fn, type)
    % retrieves the number of buffers, writes or timebins in a massspec
    % possible values for types are "buffers", "writes" and "timebins"
    % returns 0 if the type is unknown or the file is not found
    
    % try to read file
    try
        fileinfo = h5info(fn, '/FullSpectra/TofData');
    catch
        errorStruct.message = 'File not found.';
        errorStruct.identifier = 'h5:fileNotFound';
        error(errorStruct);
    end
    
    sizes = fileinfo.Dataspace.Size;
    switch type
        case 'buffers'
            value = sizes(3);
        case 'writes'
            value = sizes(4);
        case 'timebins'
            value = sizes(1);
        otherwise
        errorStruct.message = 'Unknown instance type!';
        errorStruct.identifier = 'h5:instanceUnknown';
        error(errorStruct);
    end
    
    return;
end