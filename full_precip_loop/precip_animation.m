%%%%%%%%%%%%%%%% EOF example video using ENSO etc. %%%%%%%%%%%%%%%%
clear
clc

fname=('fcstrodeo_mask.nc');
lon=ncread(fname,'lon'); % Range -125 to -93 deg
lon = lon+0.5;
lon=(lon(1:end-1))';
lat=ncread(fname,'lat'); % Range 25 to 50 degrees
lat = lat-0.5;
lat=lat(1:end-1);
[Lon,Lat]=meshgrid(lon,lat);

filex = 'prcp_14day_mean_1951_2021.mat';
datax = load(filex);

prcp1 = datax.prcp_poly_14day/1000; % convert to meters
nt = size(prcp1,3);
whos

% Set/View time range 
start = datetime('1951-01-01');
t = start + days(0:nt-1);
datestr(t([1 end]));

% Change Nan Values to 0
prcp1(isnan(prcp1))=0; % set nan values = 0


%%%%%%%%%%%%%%%% Precipitation Animation %%%%%%%%%%%%%%%%%%%

% Create a VideoWriter object
videoFile = 'figures/precip.mp4';
videoObj = VideoWriter(videoFile, 'MPEG-4');
videoObj.FrameRate = 10; % Adjust the frame rate as needed
open(videoObj);

%maxValue = max(prcp1(:));

for i = 14:nt;
    pcolor(lon,lat,prcp1(:,:,i)) ;
    shading interp ;
    %borders;
    c = colorbar;
    caxis([0, 0.05]);
    c.Label.String = 'Cumulative Mean 14-Day Precipitation (m)';
    title('Date: ', datestr(t([i])));
    ylabel('Latitude {\circ}');
    xlabel('Longitude {\circ}');
    writeVideo(videoObj, getframe(gcf));
    pause(0.1);
    close(gcf);
end;

close(videoObj);

