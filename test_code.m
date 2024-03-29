% Test

fname=('fcstrodeo_mask.nc');
lon=ncread(fname,'lon'); % Range -125 to -93 deg
lon = lon+0.5;
lon=(lon(1:end-1))';
lat=ncread(fname,'lat'); % Range 25 to 50 degrees
lat = lat-0.5;
lat=lat(1:end-1);
[Lon,Lat]=meshgrid(lon,lat);
mask=ncread(fname,'mask'); % O's and 1's grid
mask=mask';

file = 'prcp_poly_14day_1951_1951.mat';
load(file);
prcp1 = prcp_poly_14day/1000; % convert from mm to m
nt = size(prcp1,3);
whos

prcp_reg=NaN(nt,1);
for i=14:nt
    prcp_reg(i) = mean(prcp1(:,:,i), 'all');
end

prcp_reg(isnan(prcp_reg)) = 0; % previously nan values
%prcp_reg = prcp_reg/1000; % convert to meters

start = datetime('1951-01-01');
t = start + days(0:nt-1);
datestr(t([1 end]));

% Note --> prcp_reg has daily regional average precipitation 
% --> prcp1 has daily temperature observation for each obs point
%%

% 1. Deaseason data (regional and daily) - remove trend
% 2. Plot EOF - mode 1 (Mode amplitude vs time)
% 3. Plot percent variance - expvar
% 4. Spatial visualization of EOF/var

% If we don't remove seasonal cycle, the first mode represents seasonal
% variability

%eof_reg = eof(prcp_reg);
eof_reg_ds = eof(prcp_reg_ds);
[eof_reg,pc_reg,expvar_reg] = eof(prcp_reg_ds);

prcp1_ds = deseason(prcp1,t,'daily');
[eof_daily,pc,expvar] = eof(prcp1_ds);

% returns the principal component time series pc whose rows each represent 
% a different mode from 1 to n and columns correspond to time 
% steps. For example, pc(1,:) is the time series of the first 
% (dominant) mode of varibility. The third output expvar is the 
% percent of variance explained by each mode. 

% Alternative: Detrend instead of deseason? In tutorial they detrend THEN
% deseason the data before EOF analysis. 

% Detrend data
prcp1_dt = detrend3(prcp1,t,3);
prcp_reg_dt = detrend(prcp_reg);
% Deseason the detrended data
prcp1_dtds = deseason(prcp1_dt,t,'daily');
prcp_reg_dtds = deseason(prcp_reg_dt, t, 'daily');
[eof_reg,pc_reg,expvar_reg] = eof(prcp_reg_dtds);
[eof_daily,pc,expvar] = eof(prcp1_dtds);

figure;
plot(t, (prcp_reg_dt - prcp_reg_ds))
hold off
%%

figure
subsubplot(3,1,1)
plot(t,pc(1,:))
box off
axis tight
ylabel 'pc1'
title 'The first three principal components'

subsubplot(3,1,2)
plot(t,pc(2,:))
box off
axis tight
set(gca,'yaxislocation','right')
ylabel 'pc2'

subsubplot(3,1,3)
plot(t,pc(3,:))
box off
axis tight
ylabel 'pc3'
datetick('x','keeplimits')


%%

figure('Position', [200, 100, 3000, 400]); 
for i = 1
    subplot(2, 5, i); 
    plot(t, eof_reg(i,:)); 
    title(sprintf('Mode %d', i));
    if i == 8
        xlabel('Time'); 
    end
    if i == 1 || i == 6
        ylabel('Mode Amplitude');
    end
end
hold off
sgtitle('Deseasoned Regional Daily Precipitation - EOF Modes 1-10');

%%
t = datestr(t)

figure
anomaly(t,pc)
axis tight
%xlim([datenum('jan 1, 1951') datenum('jan 1, 1995')])
%datetick('x','keeplimits')

