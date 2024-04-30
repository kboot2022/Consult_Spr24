file1 = 'prcp_poly_14day_1951_1971.mat';
data1 = load(file1);

% Load the second .mat file
file2 = 'prcp_poly_14day_1972_1999.mat';
data2 = load(file2);

% Load the second .mat file
file3 = 'prcp_poly_14day_2000_2021.mat';
data3 = load(file3);


% Concatenate the contents of the three .mat files
prcp_poly_14day= cat(3, data1.prcp_poly_14day, data2.prcp_poly_14day,data3.prcp_poly_14day);

% Save the combined data into a new .mat file
file_name = 'prcp_14day_mean_1951_2021.mat';
save(file_name, 'prcp_poly_14day');
