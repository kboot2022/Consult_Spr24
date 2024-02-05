clear
clc

%%%%%%% Import grid mask to restrict netcdf data %%%%%%%%%%%%%

fname=('fcstrodeo_mask.nc');

mask_lon=ncread(fname,'lon'); % Range -125 to -93 deg
mask_lat=ncread(fname,'lat'); % Range 25 to 50 degrees
mask=ncread(fname,'mask'); % O's and 1's grid
[mask_X,mask_Y]=meshgrid(mask_lon,mask_lat);

mask_X=mask_X(:); % concatenates mask_X into one long array
mask_Y=mask_Y(:);
mask=mask(:);

indx=find(mask==1); % Find index where mask exists
mask_X=mask_X(indx); % Refine coords to mask locations
mask_Y=mask_Y(indx);
nmask=length(mask_X);

subdir = '/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/data/';
d = dir([subdir, 'ncdd-*-grd-scaled.nc']);
P = []; 
nt=25932; % 25,932 days between 01/01/1951 and 12/31/2021
P_results_daily=NaN(length(mask_X),nt);

% Individual daily precipitation

% for i=1:length(d) % 1:3  % For all NetCDF files in folder

for i=1:length(d)   
    %nt=365;
    file = [subdir, d(i).name]; % select file and read vars
    t = ncread(file,'time'); nday = length(t); 
    P = ncread(file,'prcp');

    if (i==1)
        lat = ncread(file,'lat'); ny = length(lat);
        lon = ncread(file,'lon'); nx = length(lon);
        [precip_X,precip_Y]=meshgrid(lon,lat); % set up meshgrid of precip coords
        precip_X=precip_X(:); precip_Y=precip_Y(:); % converts from grid matrix to long 1D vector
    end

    for iday=1:nday
        p=squeeze(P(:,:,iday)); 
        p=p(:);
       
        for imask=1:nmask % for length of masked grid area
            indx=find((precip_X>mask_X(imask)-.5) & (precip_X<=mask_X(imask)+.5)...
            & (precip_Y>mask_Y(imask)-.5) & (precip_Y<=mask_Y(imask)+.5) );
            
            P_results_daily(imask,iday)=sum(p(indx),'omitnan');
        end 
    end
end 

save('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/P_results_daily.mat', 'P_results_daily');

% 14 day accum -- Running total volume 

%Initialize storage dataframes
P_results=NaN(length(mask_X),nt);
P_results_meters=NaN(length(mask_X),nt);
P_results_volume=NaN(length(mask_X),nt);
grid_element_area=NaN(size(mask_X));

dlat = abs(mask_lat(2) - mask_lat(1)); % constant value 1 degree
earth_rad = 6371000; %meters -- assumes a spherical earth
dlat_meters = dlat * pi * earth_rad / 180;
dlon = 1;
dlon_meters=NaN(size(mask_X));

for imask=1:nmask
    latitude_at_grid = (mask_Y(imask)); 
    dlon_meters(imask) = dlon * pi * earth_rad * cosd(latitude_at_grid)/ 180;
    grid_element_area(imask) = dlon_meters(imask) * dlat_meters;
    for iday=14:nt
        P_results(imask,iday)=sum(P_results_daily(imask,iday-13:iday));
        P_results_meters(imask,iday) = P_results(imask,iday)/1000;
        for i = 1:length(grid_element_area)
            P_results_volume(imask, iday) =  grid_element_area(i) * P_results_meters(imask, iday);
        end
    end
end

save('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/P_results_volume.mat', 'P_results_volume');


%%

% Add to the reference date
ref_date = datenum('1800-01-01 00:00:00', 'yyyy-mm-dd HH:MM:SS'); % Add t days to the reference date; 

% convert to double type for and add to datestr t.
date = double(ref_date + t); nt = length(date);

%datestr(date); 

%% 14 day accum -- Section

%{
i14 = 1;
nt14 = round(nt/14); % Total days divided by 14
P_results_section14=NaN(length(mask_X),nt14);

for imask=1:nmask
    for i = 1:round(length(P_results_daily)/14)
        P_results_section14(imask,i) = sum(P_results_daily(i14:i14+13), 'omitnan');
        i14 = i14+14;
    end 
end
%}

