clear
clc

%%%%%%% Import grid mask to restrict netcdf data %%%%%%%%%%%%%

fname=('fcstrodeo_mask.nc');
lon=ncread(fname,'lon'); % Range -125 to -93 deg
lat=ncread(fname,'lat'); % Range 25 to 50 degrees
mask=ncread(fname,'mask'); % O's and 1's grid
[Lonmask,Latmask]=meshgrid(lon,lat);
mask=mask';

% ORIG CODE: Concatenate precip through files - one year

prcp_ann=[];

for mon=1:12; % set number of months here 
    om=num2str(100+mon); 
    ncf=['/Users/kboothomefolder/OneDrive_UNCW/x_consult/precip/data/ncdd-1951', num2str(om(2:3)), '-grd-scaled.nc'];
    %ncf %test file name by printing

    prcp=ncread(ncf,'prcp'); 
    %prcp_mon=sum(prcp,3);
    prcp_ann=cat(3,prcp_ann,prcp);
end

% lon and lat same for every netcdf file
lonnc=ncread(ncf,'lon');
latnc=ncread(ncf,'lat');
[Lonnc,Latnc]=meshgrid(lonnc,latnc);

Lonnc=Lonnc';
Latnc=Latnc';

% 14-day accumulation at each observation point

% need to add sum of leftover days to account for days 
% non-divisible by 14.

% 14-day intervals in precip data
    % --> size of the third dimension(daily prcp values) 
    % divided by 14, rounded down to a whole number

% sum together precipitation values along the third dimension of
    % prcp_ann (time) within 2 wk range 
    %%biwk=1:floor(size(prcp_ann,3))/14); prcp_14day=sum(prcp_ann(:,:,(biwk-1)*14+1:biwk*14),3); Divides into
    %into bi-weekly chunks

% update prcp_14day so that first 14 days of 1951 are NaN for all lat lon
% values

for biwk=14:size(prcp_ann,3) 

% Calculate running 14-day precipitation sum
    prcp_14day=sum(prcp_ann(:,:,biwk-13:biwk),3);
    prcp_14day(isnan(prcp_14day))=0; % set nan values = 0

% Sum 14-day precip within bounds of 1 degree grid squares

    for i=1:size(Lonmask,1)-1;
        for j=1:size(Lonmask,2)-1;
            poly(:,1)=[Lonmask(i,j), Lonmask(i,j+1),Lonmask(i+1,j+1),Lonmask(i+1,j),Lonmask(i,j)];
            poly(:,2)=[Latmask(i,j), Latmask(i,j+1),Latmask(i+1,j+1),Latmask(i+1,j),Latmask(i,j)];
            fl=inpolygon(Lonnc,Latnc,poly(:,1),poly(:,2));
            prcp_poly_14day(i,j,biwk)= sum(prcp_14day(find(fl==1)));
        end
    end
end

save('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/prcp_poly_14day_1951.mat', 'prcp_poly_14day');

