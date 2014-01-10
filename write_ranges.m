function write_ranges(ranges,file)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fileID = fopen(file,'w');

% maxmoleculesperrange=0;
% for i=1:length(ranges)
%     maxmoleculesperrange=max(maxmoleculesperrange,length(ranges{i}.molecules));
% end

%fprintf(fileID,'Name\tRange\tArea\tAreaerror\tMass offset\tMass offset error\tResolution\tResolution error\n');
% for j=1:maxmoleculesperrange
%     for i=1:length(ranges)
        % if j<=length(ranges{i}.molecules)
        %             fprintf(fileID,'%s\t%i\t%e\t%e\t%e\t%e\t%e\t%e\n',...
        %                 ranges{i}.molecules{j}.name,...
        %                 i,...
        %                 ranges{i}.molecules{j}.area,...
        %                 ranges{i}.molecules{j}.areaerror,...
        %                 ranges{i}.massoffset,...
        %                 ranges{i}.massoffseterror,...
        %                 ranges{i}.resolution,...
        %                 ranges{i}.resolutionerror);
        %  end
        

fprintf(fileID,'Name\tRange\tArea\tAreaerror\tMass offset\tMass offset error\tResolution\tResolution error\n');

for i=1:length(ranges)
    for j=1:length(ranges{i}.molecules)
        fprintf(fileID,'%s\t%i\t%e\t%e\t%e\t%e\t%e\t%e\n',...
            ranges{i}.molecules{j}.name,...
            i,...
            ranges{i}.molecules{j}.area,...
            ranges{i}.molecules{j}.areaerror,...
            ranges{i}.massoffset,...
            ranges{i}.massoffseterror,...
            ranges{i}.resolution,...
            ranges{i}.resolutionerror);
    end
end
        
        
        
% rangecount=1;
% moleculecount=1;
% n=1;
% while n<=22
%     fprintf(fileID,'%s\t\t',ranges{rangecount}.molecules{moleculecount}.name);
%     moleculecount=moleculecount+1;
%     if moleculecount>length(ranges{rangecount}.molecules)
%         moleculecount=1;
%         rangecount=rangecount+1;
%     end
%     n=n+1;
% end
% 
% fprintf(fileID,'\n');
% 
% n=1;
% for i=1:length(ranges)
%     for j=1:length(ranges{i}.molecules)
% 
%         
%         fprintf(fileID,'%e\t%e\t',...
%             ranges{i}.molecules{j}.area,...
%             ranges{i}.molecules{j}.areaerror);
%         
%         if mod(n,22)==0
%             fprintf(fileID,'\n');
%         end
%         n=n+1;
%     end
% end

fclose(fileID);

end

