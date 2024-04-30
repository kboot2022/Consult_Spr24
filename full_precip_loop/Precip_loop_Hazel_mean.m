clear
clc

%%%%%%% Import grid mask to restrict netcdf data %%%%%%%%%%%%%

fname=('fcstrodeo_mask.nc');
lon=ncread(fname,'lon'); % Range -125 to -93 deg
lat=ncread(fname,'lat'); % Range 25 to 50 degrees
mask=ncread(fname,'mask'); % O's and 1's grid
[Lonmask,Latmask]=meshgrid(lon,lat);
mask=mask';

% Sum precip over 1 deg grid squares

prcp_ann=[];

% Previously run for 1951:1:1971 and 1972:1:1999 and 2000:1:2021

year_range=[2000:1:2021]; % set number of years here, testing memory 

first_yr = num2str(year_range(1));
last_yr = num2str(year_range(end));

for i=1:length(year_range); 
    yr = year_range(i);
    oy=num2str(yr);

    for mon=1:12; % set number of months per year here 

        % construct reference year and month for each file
        om=num2str(100+mon); % format to get 0 before the month
        om=num2str(om(2:3)); % get the 1 out of month char
        oyom=[oy om];

        % Update file path
        ncf=['../data/ncdd-', oyom, '-grd-scaled.nc'];
        ncf %test file name by printing

        % read precipitation variable
        prcp=ncread(ncf,'prcp'); 
        
        % concatenate to end of prcp_ann
        prcp_ann=cat(3,prcp_ann,prcp);
        %prcp_ann=cat(# of dimensions, prcp_ann, prcp data)
        
    end

end


% lon and lat same for every netcdf file
lonnc=ncread(ncf,'lon');
latnc=ncread(ncf,'lat');
[Lonnc,Latnc]=meshgrid(lonnc,latnc);

Lonnc=Lonnc';
Latnc=Latnc';

%% Running Cumulative Precip - 14 day
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

% Note:: Doing the mean instead as per Fred

for biwk=14:size(prcp_ann,3) 

% Calculate running 14-day precipitation sum
    %prcp_14day=sum(prcp_ann(:,:,biwk-13:biwk),3);
    prcp_14day=mean(prcp_ann(:,:,biwk-13:biwk),3,'omitnan');

    %prcp_14day(isnan(prcp_14day))=0; % set nan values = 0

% Sum 14-day precip within bounds of 1 degree grid squares

    for i=1:size(Lonmask,1)-1;
        for j=1:size(Lonmask,2)-1;
            poly(:,1)=[Lonmask(i,j), Lonmask(i,j+1),Lonmask(i+1,j+1),Lonmask(i+1,j),Lonmask(i,j)];
            poly(:,2)=[Latmask(i,j), Latmask(i,j+1),Latmask(i+1,j+1),Latmask(i+1,j),Latmask(i,j)];
            fl=inpolygon(Lonnc,Latnc,poly(:,1),poly(:,2));
            prcp_poly_14day(i,j,biwk)= mean(prcp_14day(find(fl==1)),'omitnan');
	    %prcp_poly_14day(i,j,biwk)= sum(prcp_14day(find(fl==1)));
        end
    end
end

%save('prcp_poly_14day.mat', 'prcp_poly_14day'); % original save

file_path = sprintf('./prcp_poly_14day_mean_%s_%s.mat', first_yr, last_yr);
save(file_path, 'prcp_poly_14day');
