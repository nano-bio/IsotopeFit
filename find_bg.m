function [bgm,bgy,startind,endind] = find_bg(m,y,sections,level,startmass,endmass)
    %find_bg calculates a list of bgr values for a certain number of data points i.e. masses
    %   for input parmeters     m (list of masses from raw data, massaxis) 
    %                           y (list of yields from raw data, signal)
    %                           sections (= ndiv, intervall size for cutting the spec)
    %                           level (= percent, amount of data points used for bgr correction)
    %                           startmass (taken from e_startmass), endmass (taken from e_endmass)
    %   the function calculates a list of bgr values belonging to certain mass values.
    %   The output values are   bgm (list of masses)
    %                           bgy (list of background yields)
    %                           startind (index of lowest mass that will be considered)
    %                           endind (inex of highest mass that will be considered)

    % in case the start (end) mass is larger then the beginning (smaller 
    % then the end), we shorten our signal and mass axis
    
    % find first mass larger than start mass, otherwise use 1
    if startmass > m(1)
        ix1  = find(m>=startmass,1);
    else
        ix1 = 1;
    end

    % find last mass smaller than end mass, otherwise use the end
    if endmass < m(end)
        ix2 = find(m>=endmass,1);
    else
        ix2 = length(m);
    end

    % shorten
    m = m(ix1:ix2);
    y = y(ix1:ix2);

    % step = number of indices to be treated in one segment
    l = length(y);
    step = l/sections;
    
    % number of values that should be considered for each section
    nminima = round(step*level/100);

    bgm = zeros(sections, 1);
    bgy = zeros(sections, 1);
    
    % loop through all sections
    for i=1:sections;
        % retrieve all values for the current section
        signal=y(floor((i-1)*step)+1:floor(i*step));
        % sort it in ascending order
        [minmasses,~]=sort(signal);
        % cut off the values until we have included ndatapoints % of the
        % (smallest) values
        minmasses=minmasses(1:nminima);
        % calculate the center of this section
        bgm(i)=m(floor(((2*i-1)*step)/2)+1); % ????? WHY +1
        % calculate the average value of the points considered noise
        bgy(i)=mean(minmasses);
    end

    startind=ix1;
    endind=ix2;
end