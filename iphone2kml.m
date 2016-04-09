function makeKML2%(fileName)

clear all;
close all; 
clc;
format long

% log file in:
fileName = '/Users/hazlet26/Desktop/test3';

%purple: 
color = 'ffff99cc';
%color = 'ffcc0099';
colorname = 'inloco';

% blue
color = 'ffff0000';
colorname = 'blue';

% red
%color = 'ff0000ff';
%colorname = 'red';

startEpo = 1;% 1400;
endEpo = 100000;

%% Create new kml file
[path, name, ~] = fileparts(fileName);
logFile = name;
newFile = [path,'/',logFile,'.kml'];

%% Open files
fid = fopen(fileName);
fidOut = fopen(newFile,'wt');

%% Read each line
i = 1;
while ~feof(fid) ;
    tline=fgets(fid) ;
    dataLine = str2num(tline);
    N = length(dataLine);
    
    if (i == 1)
       fullN = N; 
    end
    
    
    if (N==fullN)
       dataStore(i,1:2) = dataLine(2:3);
       i = i+1;
    end  

end
numEpochs = i-1;

if endEpo > numEpochs
    endEpo = numEpochs;
end

% hour,min,sec,lat,lon,altE,hdg,spd,hAcc,vAcc,hdgAcc,spdAcc,fixType,numSvs,hdop

%% KML header
initKmlStr = InitKml();
fprintf(fidOut,initKmlStr);

%% KML Name
nameKmlStr = GetName(name);
fprintf(fidOut,nameKmlStr);

%% KML style
styleStr = GetStyle(colorname, color);
fprintf(fidOut,styleStr);

%% KML position folder
folderHeader = GetFolderHeader();
fprintf(fidOut,folderHeader);

%% KML markers
for i = startEpo:endEpo
    placemark = GetPlacemark(dataStore(i,:),i,colorname);
    fprintf(fidOut,placemark);
end

%% KML Speed vectors
%speedVecStr = GetSpeedVectors();
%fprintf(fidOut,speedVecStr);

% make string of speed vecs..

for i = startEpo:endEpo
    lat = dataStore(i,1);
    lon = dataStore(i,2);
    hdg = 0; %dataStore(i,7);
    spd = 0; %dataStore(i,8);
    alt = 10; %dataStore(i,6);
    
    [latOut,lonOut] = GetEndLatLon(lat,lon,hdg,spd);

    latStr = num2str(lat,15);
    lonStr = num2str(lon,15);
    altStr = num2str(alt,15);
    endLatStr = num2str(latOut,15);
    endLonStr = num2str(lonOut,15);
    
     adist = 0.8;
     [alat,alon] = GetNewLatLon(latOut,lonOut,adist,(hdg+180));
     [a1lat,a1lon] = GetNewLatLon(alat,alon,adist,(hdg+90));
     [a2lat,a2lon] = GetNewLatLon(alat,alon,adist,(hdg-90));

    arrow1 = [' ',num2str(lonOut,11),',',num2str(latOut,11),',',num2str(alt),' ',...
             num2str(a1lon,11),',',num2str(a1lat,11),',',num2str(alt),'\n'];

    arrow2 = [' ',num2str(lonOut,11),',',num2str(latOut,11),',',num2str(alt),' ',...
             num2str(a2lon,11),',',num2str(a2lat,11),',',num2str(alt),'\n'];

    speedVec = [' ', lonStr ,',', latStr ,',', altStr ,' ', endLonStr ,',', endLatStr ,',', altStr ,'\n'];
    if spd > 0.24
        fprintf(fidOut,'        <LineString>\n');               
        fprintf(fidOut,'            <coordinates>\n');
        fprintf(fidOut,speedVec);
        fprintf(fidOut,arrow1);
        fprintf(fidOut,arrow2);
        fprintf(fidOut,'            </coordinates>\n');
        fprintf(fidOut,'        </LineString>\n');
    end
end
%fprintf(fidOut,'        </LineString>\n');

%% KML ender
ender = GetEnder();
fprintf(fidOut,ender);

fclose all;


end
function [latOut,lonOut] = GetEndLatLon(lat,lon,heading,speed)

    radius = 6367426.73;
    refLat = lat;
    refAlt = 35;
    pi = 3.14159265;
    D2R = pi / 180.0;
    R2D = 180.0 / pi;

    N = sqrt(speed*speed / (1.0 + (tan(heading*D2R)*tan(heading*D2R))));
    E = sqrt(speed*speed - N*N);

    signN = 1.0;
    signE = 1.0;

    if (heading > 360.0)
        heading = heading - 360.0;
    end

    if (heading < 0.0)
        heading = heading + 360.0;
    end

    if (heading>90.0 && heading < 270.0)
        signN = -1.0;
    end
    if (heading >180.0 && heading < 360.0)
        signE = -1.0;
    end

    latOut = (lat*D2R + signN*N / (radius + refAlt)) * R2D;
    lonOut = (lon*D2R + signE*E / ((radius + refAlt)*cos(refLat*D2R))) *R2D;
end

function initKmlStr = InitKml()
    initKmlStr= ...
        ['<?xml version="1.0" encoding="UTF-8"?>\n' ,...
        '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n' ,...
        '<Document>\n'];
end

function name2 = GetName(name)
    name2 = ['<name> ' , name , ' </name>\n'];
end

function style = GetStyle(name, color)

    style = [...
        '<StyleMap id="' ,name,'">\n' ,...
        '   <Pair>\n' ,...
        '       <key>normal</key>\n' ,...
        '       <Style>\n' ,...
        '           <IconStyle>\n' ,...
        '               <color>' , color , '</color>\n' ,...
        '               <scale>0.21</scale>\n' ,...
        '               <Icon>\n' ,...
        '                   <href>http://maps.google.com/mapfiles/kml/paddle/purple-diamond-lv.png</href>\n' ,...
        '               </Icon>\n' ,...
        '               <hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>\n' ,...
        '           </IconStyle>\n' ,...
        '           <LabelStyle>\n' ,...
        '               <scale>0</scale>\n' ,...
        '           </LabelStyle>\n' ,...
        '       </Style>\n' ,...
        '   </Pair>\n' ,...
        '   <Pair>\n' ,...
        '       <key>highlight</key>\n' ,...
        '       <Style>\n' ,...
        '           <IconStyle>\n' ,...
        '               <color>' , color , '</color>\n' ,...
        '               <scale>0.3</scale>\n' ,...
        '               <Icon>\n' ,...
        '                   <href>http://maps.google.com/mapfiles/kml/paddle/purple-diamond-lv.png</href>\n' ,...
        '               </Icon>\n' ,...
        '               <hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>\n' ,...
        '           </IconStyle>\n' ,...
        '       </Style>\n' ,...
        '   </Pair>\n' ,...
        '</StyleMap>\n'];
end

function folderHeader = GetFolderHeader()
    folderHeader = [...
        '<Folder>\n' ,...
        '   <name>Positions</name>\n'];
end

function ender = GetEnder()
    ender = [...
        '</Folder>\n' ,...
        '</Document>\n' ,...
        '</kml>\n'];
end

function speedVecStr = GetSpeedVectors()
    speedVecStr = [...
        '</Folder>\n' ,...
        '<Placemark>\n' ,...
        '   <name>Speed Vectors</name>\n' ,...
        '   <Style>\n' ,...
        '       <LineStyle>\n' ,...
        '           <color>ffffffff</color>\n' ,...
        '           <width>1</width>\n' ,...
        '       </LineStyle>\n' ,...
        '   </Style>\n' ,...
        '   <MultiGeometry>\n'];

end

function placemark = GetPlacemark(dataLine,idx,style)

% hour,min,sec,lat,lon,altE,hdg,spd,hAcc,vAcc,hdgAcc,spdAcc,fixType,numSvs,hdop
    %style = 'purple';
    hour = '1'; %num2str(dataLine(1),15);
    min = '2'; %num2str(dataLine(2),15);
    sec = '3'; %num2str(dataLine(3),15);
    lat = num2str(dataLine(1),15);
    lon = num2str(dataLine(2),15);
    altE = num2str(100.0); %num2str(dataLine(6),15);
    hdg = '0'; %num2str(dataLine(7),15);
    spd = '0'; %num2str(dataLine(8),15);
    hAcc = '0'; %num2str(dataLine(9),15);
    vAcc = '0'; %num2str(dataLine(10),15);
    hdgAcc = '0'; %num2str(dataLine(11),15);
    spdAcc = '0'; %num2str(dataLine(12),15);
    fixType = '0'; %num2str(dataLine(13),15);
    numSvs = '0'; %num2str(dataLine(14),15);
    hdop = '0'; %num2str(dataLine(15),15);
    
    time = [hour,',',min,',',sec];
    lla = [lon,',',lat,',',altE];
    
        %'           <description>Time: ' , time , ' \n' ,...
        %'Lat : ' , lat , ' \n' ,...
        %'Lon : ' , lon , ' \n' ,...
        %'alt(ellip) : ' , altE , ' \n' ,...
        %'heading: ' , hdg , ' \n' ,...
        %'speed : ' , spd , ' \n' ,...
        %'hAcy, vAcy, spdAcy, hdgAcy : ' , hAcc ,' ', vAcc ,' ', spdAcc ,' ', hdgAcc , '\n' ,...
        %'fix mode : ' , fixType , '\n' ,...
        %'num SVs : ' , numSvs , ' \n' ,...
        %'hdop : ' , hdop , ' \n' ,...
        %'           </description>\n' ,...
    
    placemark = [...
        '       <Placemark>\n' ,...
        '           <name>Index: ' , num2str(idx) , ' </name>\n' ,...
        '           <styleUrl>#' , style , '</styleUrl>\n' ,...
        '           <Point>\n' ,...
        '              <coordinates>' , lla , '</coordinates>\n' ,...
        '           </Point>\n' ,...
        '       </Placemark>\n'];
end

function [lat,lon] = GetNewLatLon(lat1,lon1,dist,hdg)

radius = 6367426.73;
refLat = lat1;
refAlt = 35;

N = sqrt(dist^2/(1+tan(hdg*pi/180)^2));
E = sqrt(dist^2-N^2);

signN = 1;
signE = 1;

if hdg>360
    hdg = hdg-360;
end
if hdg<0
   hdg = hdg+360;
end

if hdg>90 && hdg<270
   signN = -1;
end
if hdg >180 && hdg <360
   signE = -1;
end

lat = (lat1*pi/180+signN*N/(radius+refAlt))*180/pi;
lon = (lon1*pi/180 + signE*E/((radius+refAlt)*cos(refLat*pi/180)))*180/pi;
end







