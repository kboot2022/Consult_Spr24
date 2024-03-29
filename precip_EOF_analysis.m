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


% use eof function
% set n to 10 or 20 (start with 10)
% three dimensions (lat, lon, time)
% eof for regional data, not individual square (reduce dimensionality)

% https://www.youtube.com/watch?v=A5UjLO-67GQ

% Load example data: 
%file = 'prcp_poly_14day_1951_1953.mat';
file = 'prcp_poly_14day_1951_1951.mat'; % this is the mean precip for each grid in mm
load(file);
prcp1 = prcp_poly_14day/1000; % convert to meters
nt = size(prcp1,3);
%whos

% Set/View time range 
start = datetime('1951-01-01');
t = start + days(0:nt-1);
datestr(t([1 end]));

% View temporal resolution/timestep of each observation
mean(diff(t));

% Find regional sum for each timestep (1 day)
prcp_reg=NaN(nt,1); % we should get 1096 regional values

% Change Nan Values to 0
prcp1(isnan(prcp1))=0; % set nan values = 0

for i=14:nt
    prcp_reg(i) = mean(prcp1(:,:,i), 'all'); % change to 'omitnan'?
end

%%%%% comment this out?
prcp_reg(isnan(prcp_reg)) = 0; % set Nans to 0 value (mean already calculated)

% Remove the seasonal cycle: 
% deseason function removes the seasonal (aka annual) cycle of variability from a time series.
%prcp_reg_ds = deseason(prcp_reg,t,'daily');
%prcp1_ds = deseason(prcp1,t,'daily');
%prcp_reg_ds_trend = trend(prcp_reg_ds);
%prcp1_ds_trend = trend(prcp1_ds);
%[prcp_reg_ds_trend,p] = trend(prcp_reg_ds);
%[prcp1_ds_trend,p] = trend(prcp1_ds);
%mk_ds = mann_kendall(prcp_reg_ds)
%mk1_ds = mann_kendall(prcp1_ds)
%mann_kendall(rand(size(prcp_reg_ds)))
%mann_kendall(rand(size(prcp1_ds)))
%%%%%%%%% Calculate EOF's for detrended datasets 

% Detrend data and calculate trends with statistical p values: 
prcp1_dt = detrend3(prcp1,t,3);
prcp_reg_dt = detrend(prcp_reg);
% Deseason the detrended data % Not needed for now, only detrending
prcp1_dtds = deseason(prcp1_dt,t,'daily');
prcp_reg_dtds = deseason(prcp_reg_dt, t, 'daily');

% Calculate trends with statistical p values: 
[prcp_reg_trend,p] = trend(prcp_reg);
[prcp_reg_dt_trend,p_regdt] = trend(prcp_reg_dt);
[prcp1_dt_trend,p1] = trend(prcp1_dt);

% Determine if the trend is significant: 
% mann_kendall performs a standard simple Mann-Kendall test to determine the presence of a significant trend. (Requires the Statistics Toolbox)
mk = mann_kendall(prcp_reg);
% Verify that random numbers do not produce a significant trend: 
mann_kendall(rand(size(prcp_reg)));

% EOF analysis regional mean
[eof_reg_dt,pc_reg_dt,expvar_reg_dt] = eof(prcp_reg_dt);
[eof_reg_dtds,pc_reg_dtds,expvar_reg_dtds] = eof(prcp_reg_dtds);

[eof_daily_dtds,pc_dtds,expvar_dtds] = eof(prcp1_dtds);
[eof_daily_dt,pc_dt,expvar_dt] = eof(prcp1_dt);
%% %%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% 0. Total Daily Mean of Cumulative 14-day Precipitation for grid area 
figure;
imagescn(lon,lat,mean(prcp1,3,'omitnan'));
axis xy off;
cb = colorbar;
xlabel 'Longitude';
ylabel 'Latitude';
ylabel(cb,' Mean Precipitation (m)');
title('Mean Daily 14-day Cumulative Precipitation');
cmocean thermal;
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/0_mean_cumulative_daily_precip.png', '-dpng', '-r300');

%%%%% 00. Spatial Decadal Precipitation Trend
figure;
imagescn(lon,lat,10*365.25*trend(prcp1,3))
axis xy off
cb = colorbar;
xlabel 'Longitude';
ylabel 'Latitude';
ylabel(cb,' Decadal Precipitation trend (m)')
cmocean('balance','pivot')
title('Decadal Precipitation Trend 1951 - 2021')
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/00_decadal_precip_trend.png', '-dpng', '-r300');


%%%%% 000. DT - Regional 
figure;
%plot(t, prcp_reg);
% hold on
plot(t, prcp_reg_dt);
% hold on
%plot(t, prcp_reg_dtds);
% hold on
%legend('Regional Mean Precip', 'Deseasoned Regional', 'Dt + Ds Regional');
legend('Detrended Precipitation');
title('Detrended Signal Regional Precipitation');
xlabel('Time');
ylabel('Mean Regional Precipitation (m)');
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/000_regional_dtds_comparison.png', '-dpng', '-r300');


%%%%% 1. Regional Daily Mean Precip Time Series
plot(t,prcp_reg)
ylabel('Precipitation (m)')
xlabel Time
title('Regional Mean Precipitation')
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/1_regional_precip.png', '-dpng', '-r300');

%%%%% 2. Detrended (Daily) Regional Mean Precip Time Series
clf()
plot(t,prcp_reg_dt, 'red')
ylabel('Deaseasoned Precipitation (m)')
xlabel Time
title('Deseasoned Regional Mean Precipitation')
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/2_regional_precip_dt.png', '-dpng', '-r300');


%%%%%% 3. Mean Precip + Trendlines Timeseries (Regional & Detrended)
%polyplot(t,prcp_reg, 'blue', DisplayName='Regional Precipitation') %(8600 --> 7400)
%hold on
%plot(t,prcp_reg, 'blue', DisplayName='Trend')
%hold on
polyplot(t,prcp_reg_dt, 'red', DisplayName='Detrended');
hold on
plot(t,prcp_reg_dtds, 'green', DisplayName='DT + DS');
hold off
ylabel('Precipitation (m)')
title('Regional Mean Precipitation Trends')
xlabel Time
legend
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/3_regional_precip_trend.png', '-dpng', '-r300');


%%%%%% 4. Map of one-day precip example: 
imagescn(lon,lat,prcp1(:,:,14)); 
cb = colorbar; 
ylabel(cb,'Mean precipitation (m)');
ylabel('Latitude (deg)');
xlabel('Longitude (deg)');
title('Precipitation Grid ',datestr(t([14])));
cmocean thermal % sets the colormap
borders
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/4_precip_map_example.png', '-dpng', '-r300');


%%%%%%% 5. Histogram of regional average precip: 
histogram(prcp_reg, 'Normalization', 'probability')%, 'EdgeColor', 'white');
xlabel('Mean Precipitation (m)');
ylabel('Count');
title('Histogram of 14-day Mean Regional Precipitation Data');
grid on;
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/5_regional_precip_hist.png', '-dpng', '-r300');


%%%%%%%% 6. Histogram of all precip values: 
prcp1_filtered = prcp1(prcp1 > 0);
binWidth = 0.001;
maxbin = 0.02;
edges = 0:binWidth:maxbin+binWidth;
histogram(prcp1_filtered, edges, 'Normalization', 'probability', 'EdgeColor', 'white');
xlabel('Precipitation (m)');
ylabel('Count');
title('Histogram of 14-day Cumulative Mean Precipitation');
grid on;
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/6_precip_hist.png', '-dpng', '-r300');

%%%%%% 7. Plot the first EOF map:
% imagescn(lon,lat,eof_daily(:,:,14)); 
% cb = colorbar; 
% ylabel(cb,'Mean precipitation EOF');
% ylabel('Latitude (deg)');
% xlabel('Longitude (deg)');
% title('EOF Plot ',datestr(t([14])));
% cmocean thermal % sets the colormap
% borders
% hold off
% print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/7_eof_map_example.png', '-dpng', '-r300');

%%%%%%%%%% 8. Power spectral density (PSD) regional 
figure;
plotpsd(prcp_reg,12,'logx','lambda')
hold on
plotpsd(prcp_reg_dt,12,'logx','lambda')
xlabel 'periodicity (years)'
title('Regional Precipitation PSD Periodicity');
legend('Original', 'Detrended'); 
set(gca,'xtick',[1:7 33])
hold off 
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/8_psd_periodicity_regional.png', '-dpng', '-r300');

%%%%%%%% 9. PSD all 
figure;
prcp1_all = squeeze(prcp1(:));
prcp1_all_dt = squeeze(prcp1_dt(:));
plotpsd(prcp1_all,12,'logx','lambda')
hold on
plotpsd(prcp1_all_dt,12,'logx','lambda')
xlabel 'periodicity (years)'
title('Precipitation Grid (All Values) PSD Periodicity');
legend('Original', 'Detrended'); 
set(gca,'xtick',[1:7 33])
hold off 
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/9_psd_periodicity_all.png', '-dpng', '-r300');

%%%%%%%% 10. EOF Modes 1-10 
figure('Position', [200, 100, 3000, 400]); 
for i = 1:10
    subplot(2, 5, i); 
    plot(t, pc_dt(i,:)); 
    title(sprintf('Mode %d', i));
    if i == 8
        xlabel('Time'); 
    end
    if i == 1 || i == 6
        ylabel('Mode Amplitude');
    end
end
hold off
sgtitle('Detrended Daily Precipitation - EOF Modes 1-10'); % from Matlab2018 old, suptitle not available?
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/10_eof_daily_dt_10modes.png', '-dpng', '-r300');


%%%%%%%% 11. Remaining variance of precipitation (dt only) 
figure;
imagescn(lon,lat,var(prcp1_dt,[],3));
axis xy off;
colorbar;
title('Remaining Variance of Precipitation');
colormap(thermal);
caxis([0 1])
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/11_DTDSdaily_remaining_variance.png', '-dpng', '-r300');


% 12. Plot the first EOF mode

figure
imagesc(lon,lat,eof_daily_dt(:,:,1))
axis xy image
colormap(cmocean('curl','pivot'));
colorbar;
title 'EOF Mode 1 - Cumulative Daily Precipitation'
hold off
print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/12_daily_eof_Mode1.png', '-dpng', '-r300');


% 13. The first three principal components

figure
subsubplot(3,1,1)
plot(t,pc_dt(1,:))
box off
axis tight
ylabel 'pc1'
title 'The first three principal components'

subsubplot(3,1,2)
plot(t,pc_dt(2,:))
box off
axis tight
set(gca,'yaxislocation','right')
ylabel 'pc2'

subsubplot(3,1,3)
plot(t,pc_dt(3,:))
box off
axis tight
ylabel 'pc3'
datetick('x','keeplimits')
hold off 

print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/13_daily_eof_ModeComp.png', '-dpng', '-r300');


%% %%%%%%%%%%%%%%%% Precipitation Animation %%%%%%%%%%%%%%%%%%%

% Create a VideoWriter object
videoFile = '/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/precip.mp4';
videoObj = VideoWriter(videoFile, 'MPEG-4');
videoObj.FrameRate = 10; % Adjust the frame rate as needed
open(videoObj);

maxValue = max(prcp1(:));

for i = 14:nt;
    pcolor(lon,lat,prcp1(:,:,i)) ;
    shading interp ;
    borders;
    c = colorbar;
    caxis([0, 120]);
    c.Label.String = 'Cumulative Precipitation (m)';
    title('Date: ', datestr(t([i])));
    ylabel('Latitude {\circ}');
    xlabel('Longitude {\circ}');
    writeVideo(videoObj, getframe(gcf));
    pause(0.1);
    close(gcf);
end;

close(videoObj);

%% 

% Calculate SST trend (deg/yr): 
sst_trend = 365.25*trend(sst,t,3);

% Map the SST trend: 
imagescn(lon,lat,10*sst_trend)
cb = colorbar; 
ylabel(cb,' temperature trend {\circ}C per decade ') 
cmocean('balance','pivot') 

% Plot the first mode of the raw SST: 
imagescn(lon,lat,eof(sst,1))
colorbar; 
cmocean('balance','pivot') 
title 'eof first mode'

% Mark a location of interest: 
hold on
plot(lon(12),lat(10),'ks') 
hold off

% Get the time series at the location of interest: 
sst1 = squeeze(sst(10,12,:)); 
plot(t,sst1)
datetick     % formats the date axis

% Remove the seasonal cycle: 
sst1_ds = deseason(sst1,t); 
hold on
plot(t,sst1_ds)
hold off

% Remove seasonal cycle from the data: 
sst_ds = deseason(sst,t); 

% Plot the first mode of the deseasoned data: 
imagescn(lon,lat,eof(sst_ds,1))
colorbar
cmocean('balance','pivot') 

% Remove long-term trend:
sst_ds_dt = detrend3(sst_ds); 

% Recreate Fig 2a of Messie & Chavez 2011 http://dx.doi.org/10.1175/2011JCLI3941.1
sst_anom_var = var(sst_ds_dt,[],3);
imagescn(lon,lat,sst_anom_var); 
colorbar
title('variance of temperature') 
colormap(jet) % jet is inexcusable except when recreating old plots
caxis([0 1])

% Calculate eofs: 
[eof_maps,pc,expv] = eof(sst_ds_dt,6);

whos eof_maps pc expv

clf % clears the previous figure
subplot(3,2,1)
imagescn(lon,lat,eof_maps(:,:,1))
axis off
cmocean('bal','pivot') 
axis image

% Plot the time series of the first mode: 
subplot(3,2,2)
plot(t,pc(1,:))
axis tight
box off
datetick

subplot(3,2,3)
imagescn(lon,lat,eof_maps(:,:,2))
axis off
cmocean('bal','pivot') 
axis image 

subplot(3,2,6)
plot(t,pc(3,:))
axis tight
box off
datetick

subplot(3,2,5)
imagescn(lon,lat,eof_maps(:,:,3))
axis off
cmocean('bal','pivot') 
axis image 

subplot(3,2,4)
plot(t,pc(2,:))
axis tight
box off
datetick

sgtitle 'The first three principal components'

% Explained variance: 
expv 

clf 
% Map the observed SST anomaly of timestep 1: 
subplot(1,2,1) 
h1 = imagescn(lon,lat,sst_ds_dt(:,:,1)); 
title 'observed sst anomaly' 
cmocean bal
caxis([-1 1]*2.5) 
axis image

% Map the mode 1 anomaly of timestep 1: 
subplot(1,2,2) 
h2 = imagescn(lon,lat,eof_maps(:,:,1)*pc(1,1)); 
title 'reconstructed sst anomaly' 
cmocean bal
caxis([-1 1]*2.5) 
axis image
sgtitle(datestr(t(1),'yyyy-mmm-dd'))

% Reconstruct an SST anomaly map: 
h2.CData = eof_maps(:,:,1)*pc(1,1) + ...
           eof_maps(:,:,2)*pc(2,1) + ...
           eof_maps(:,:,3)*pc(3,1) + ...
           eof_maps(:,:,4)*pc(4,1) + ...
           eof_maps(:,:,5)*pc(5,1) + ...
           eof_maps(:,:,6)*pc(6,1);

% Reconstruct sst anomalies from first 5 modes:
sst_ds_dt_r = reof(eof_maps,pc,1:5); 

% Animate the two time series: 
for k = 1:120
   h1.CData = sst_ds_dt(:,:,k); 
   h2.CData = sst_ds_dt_r(:,:,k); 
   pause(0.1)
   sgtitle(datestr(t(k),'yyyy-mmm-dd'))
end

% Tip: Check out the gif function! 

% Define the Nino 3.4 box: 
latrange = [-5 5]; 
lonrange = [-170 -120]; 

% Create a Nino 3.4 mask: 
mask = geomask(Lat,Lon,latrange,lonrange);

% Plot the mask outline: 
hold on
contour(lon,lat,mask,[.5 .5],'k') 

% Area of each grid cell: 
A = cdtarea(Lat,Lon); 

% Area-weighted SST anomaly time series: 
sst_anom_34 = local(sst_ds_dt,mask,'weight',A); 

clf
anomaly(t,sst_anom_34,'color','none')
axis tight
box off
datetick
ylabel 'sst anomaly \circC'

idx = enso(sst,t,Lat,Lon); 
hold on
plot(t,idx,'k')
text(t([396 575 792]),idx([396 575 792]),...
   'El Nino!','horiz','center','vert','bot')

clf
plot(idx,pc(1,:),'.')
hold on
polyplot(idx,pc(1,:))

pc1_scale = trend(idx,pc(1,:))

clf
anomaly(t,idx)
hold on
plot(t,pc1_scale*pc(1,:),'color',rgb('gold'),'linewidth',2)
axis tight
datetick 

text(t([396 575 792]),idx([396 575 792]),...
   'El Nino!','horiz','center','vert','bot')