% Figures  

%%%%%%%%%%%%%%%%%%% Time series %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Daily 14-day running precip total
% total precipitation volume in the region per day of the month

data = 'prcp_poly_14day_1951.mat'
load(data);

whos('-file', 'prcp_poly_14day_1951.mat')
prcp1 = prcp_poly_14day;
[nlon, nlat, nt] = size(prcp1);

% 
% Find regional sum for each timestep (1 day)
prcp_regional=NaN(nt, 1); % we should get 365 regional values
%figure;

for i=14:nt
    prcp_regional(i) = mean(prcp1(:,:,i), 'all');
end

%
% Specify the date 
start = datetime('1951-01-01');
total_time = nt;  
date = start + days(0:total_time-1);
%date_string = datestr(date, 'mm-dd-yyyy');
%disp(date);

%% %%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regional Mean Precip Time Series
plot(date, prcp_regional,'b', 'LineWidth', 2);
xlabel('Month');
ylabel('Precipitation (mm)');
title('Cumulative Precipitation in Southwestern US Region - 1951');
legend('Precipitation');

print('/Users/kboothomefolder/Library/CloudStorage/OneDrive-UNC-Wilmington/x_consult/precip/figures/regional_precip_1951.png', '-dpng', '-r300');

%%%%%%%%%%%%%%%%%%%% Histogram

