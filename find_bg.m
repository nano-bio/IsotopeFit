function [bgm,bgy,startind,endind] = find_bg(m,y,sections,level,startmass,endmass)
    % This function takes a mass axis and a signal axis and computes the 
    % average of the lowest level% of the signal points for n sections 
    % (equally dividing the axes). It can be restricted by start and
    % endmasses (and returns them).

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

    % ????? WHY SORT?
    [bgm,ix]=sort(bgm);
    bgy=bgy(ix);

    startind=ix1;
    endind=ix2;
end