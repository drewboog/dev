function FordTraceToJindo


clc; clear all, fclose all;
format long;
hold on
axis equal;

% log file in:
fileName = '/Users/hazlet26/Desktop/ForthFiles/ThanksgivingFordtracefilefull.json';

% out file
newFile = '/Users/hazlet26/Desktop/ForthFiles/fordsfLog1-out.log';

%% Open files
fid = fopen(fileName);
fidOut = fopen(newFile,'wt');

%% Read each line
i = 1;
idx = 0;
idxTemp = 0;
while ~feof(fid) ;
    tline=fgets(fid) ;
    dataLine = str2num(tline);
    %disp(tline)
    i = i+1;
    %if i > 20000
    %   break; 
    %end
    
    if strfind(tline,'latitude')
       stIdx = strfind(tline,'"value":')+8;
       endIdx = strfind(tline,',"times')-1;
       valStr = tline(stIdx:endIdx);
       val = str2num(valStr);
       idx = idx+1;
       %dataStore(idx,1:15)=ones(1,15)*0;
       %dataStore(idx,4)=val;
       latStr = valStr;
       if idx > 1000*idxTemp
           idxTemp = idxTemp+1;
          disp(idx) 
          
       end
       if idx> 6000
          break; 
       end
       %disp(1)
    end
    if strfind(tline,'longitude')
       stIdx = strfind(tline,'"value":')+8;
       endIdx = strfind(tline,',"times')-1;
       valStr = tline(stIdx:endIdx);
       val = str2num(valStr);
       %dataStore(idx,5)=val;
       lonStr = valStr;
       %disp(1)
    end
    if strfind(tline,'vehicle_speed')
       if idx>5000
       stIdx = strfind(tline,'"value":')+8;
       endIdx = strfind(tline,',"times')-1;
       valStr = tline(stIdx:endIdx);
       val = str2num(valStr);
       %dataStore(idx,8)=val;
       spdStr = valStr;
       lineOut = ['0,0,0,',latStr,',',lonStr,',0,0,',spdStr,',0,0,0,0,0,0,0\n']; 
       %if idx>6000
        fprintf(fidOut,lineOut);
       end
       %disp(1)
    end
    
end

%% write out data
% tic
% N = idx;
% for i = 1:N
%     lineOut = num2str(dataStore(i,1:15));
%     fprintf(fidOut,lineOut);
%     fprintf(fidOut,'\n');
% end
% toc
disp(idx)
fclose all;

end