%Create a netcdf file

%Go to the directory where you wan the file to be created. 
cd /Users/westbrooke/Library/CloudStorage/OneDrive-UNC-Wilmington/SMODE/PFC/PFC_REVISED

%First create the file with ncid = netcdf.create('filename.nc','MODE') You will
%likely want to set the mode to 'NETCDF4' as I have here. But there are a
%few to choose from if you look this function up on mathworks. 

%Note that if you want to open a file for editing that already exists, you
%can use netcdf.open('file_name','NC_WRITE') or
%netcdf.open('file_name','NC_NOWRITE') depending if you want read only or
%not. 
ncid = netcdf.create('combined_data.nc','NETCDF4');

%Next, define the dimensions in the file with
%netcdf.defDim(ncid,'dimension_name',dimension_length)
dimidt = netcdf.defDim(ncid,'time',length(time));


%Then define the variable names with
%netcdf.defVar(ncid,'variable_name','variable_type',[variable dimensions]). If more than
%one dimension is used, you will want to put them in brackets
%[dimension1,dimension2]
time_ID = netcdf.defVar(ncid,'time','double',dimidt);
lat_ID = netcdf.defVar(ncid,'latitude','double',dimidt);
lon_ID = netcdf.defVar(ncid,'longitude','double',dimidt);
pres_ID = netcdf.defVar(ncid,'pressure','double',dimidt);
sal_ID = netcdf.defVar(ncid,'salinity','double',dimidt);
temp_ID = netcdf.defVar(ncid,'temperature','double',dimidt);
ID_ID = netcdf.defVar(ncid,'ID','int64',dimidt);

%If any of your variables have fill values, this is where you will define
%them with netcdf.defVarFill(ncid,varid,false,fill_value). They need to be defined before the first time you use
%netcdf.endDef()
netcdf.defVarFill(ncid,sal_ID,false,-9999)
netcdf.defVarFill(ncid,temp_ID,false,-9999)

%this function switches us from metadata entry mode to what I beleive is a
%data entry mode. before calling netcdf.endDef(ncid), you won't be able to
%see changes you ahve made to the metadata when you call ncdisp(fname). 
netcdf.endDef(ncid)

%This section inputs the variable data with
%netcdf.putVar(ncid,varid,var_data). In this case the variables time, lat,
%lon, pres, temp, sal, and ID are all double variables that are already
%loaded in your workspace. 
netcdf.putVar(ncid,time_ID,time)
netcdf.putVar(ncid,lat_ID,lat)
netcdf.putVar(ncid,lon_ID,lon)
netcdf.putVar(ncid,pres_ID,pres)
netcdf.putVar(ncid,temp_ID,temp)
netcdf.putVar(ncid,sal_ID,sal)
netcdf.putVar(ncid,ID_ID,ID)



%use netcdf.reDef(ncid) to switch back to metadata entry mode. 
netcdf.reDef(ncid)

%netcdf.putAtt(ncid,varid,'attribute_name', 'attribute_value') is used to
%add metadata. If it's vairable metadata, you just use the appropriate
%variable ID from your code above. If you are looking to add global
%metadata, you use netcdf.getConstant('NC_GLOBAL') in place of a variable
%ID. 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Temperature, Salinity, and position data of combined CTD, TSG, Waveglider, NAVOglider, Saildrone, and EcoCTD data from the S-MODE PFC campaign')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'standard_name_vocabulary','CF Standard Name Table v72')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'acknowledgement','This work is a contribution to the S-MODE project, an EVS-3 Investigation awarded under NASA Research Announcement NNH17ZDA001N-EVS3')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'license','Issued under Creative Commons CC BY 4.0: https://creativecommons.org/licenses/by/4.0/')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'product_version','1.0')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'history','none')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'project','Sub-Mesoscale Ocean Dynamics Experiment (S-MODE)')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'program','NASA Earth Venture Suborbital-3 (EVS-3)')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'sea_name','Pacific')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_vertical_units','m')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_vertical_positove','down')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'date_created',datestr(datenum(2023,11,15),'yyyy-mm-ddTHH:MM:SSZ'))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'time_coverage_start', datestr(min(time)+datenum(1950,1,1),'yyyy-mm-ddTHH:MM:SSZ'))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'time_coverage_end', datestr(max(time)+datenum(1950,1,1),'yyyy-mm-ddTHH:MM:SSZ'))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_units','degrees_east')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_units','degrees_north')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_min',min(lat))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_max',max(lat))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_min',min(lon))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_max',max(lon))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'summary','Temperature, salinity, and position data from various instruments used in the pilot campaign for intercalibration')
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'comment','ID Meanings - 1 = Shipboard CTD, 2-11 = NAVOgliders, 12-16 = Saildrones, 17 = TSG, 18-20 = Wavegliders, 21 = EcoCTD')

netcdf.putAtt(ncid,time_ID,'long_name','Time of Measurement')
netcdf.putAtt(ncid,time_ID,'axis','T')
netcdf.putAtt(ncid,time_ID,'standard_name','time')
netcdf.putAtt(ncid,time_ID,'units','days since 1950-01-01')
netcdf.putAtt(ncid,time_ID,'coverage_content_type','coordinate')

netcdf.putAtt(ncid,lat_ID,'long_name','Latitude of Measurement')
netcdf.putAtt(ncid,lat_ID,'axis','Y')
netcdf.putAtt(ncid,lat_ID,'standard_name','latitude')
netcdf.putAtt(ncid,lat_ID,'units','degrees_north')
netcdf.putAtt(ncid,lat_ID,'coverage_content_type','coordinate')

netcdf.putAtt(ncid,lon_ID,'long_name','Longitude of Measurement')
netcdf.putAtt(ncid,lon_ID,'axis','X')
netcdf.putAtt(ncid,lon_ID,'standard_name','longitude')
netcdf.putAtt(ncid,lon_ID,'units','degrees_east')
netcdf.putAtt(ncid,lon_ID,'coverage_content_type','coordinate')

netcdf.putAtt(ncid,pres_ID,'long_name','Pressure of Measurement')
netcdf.putAtt(ncid,pres_ID,'axis','Z')
netcdf.putAtt(ncid,pres_ID,'standard_name','sea_water_pressure_due_to_sea_water')
netcdf.putAtt(ncid,pres_ID,'units','dbar')
netcdf.putAtt(ncid,pres_ID,'coverage_content_type','coordinate')

netcdf.putAtt(ncid,sal_ID,'long_name','Sea Water Salinity')
netcdf.putAtt(ncid,sal_ID,'coordinates','time latitude longitude pressure')
netcdf.putAtt(ncid,sal_ID,'standard_name','sea_water_practical_salinity')
netcdf.putAtt(ncid,sal_ID,'units','1')
netcdf.putAtt(ncid,sal_ID,'valid_min','2')
netcdf.putAtt(ncid,sal_ID,'valid_max','42')
netcdf.putAtt(ncid,sal_ID,'coverage_content_type','physicalMeasurement')

netcdf.putAtt(ncid,temp_ID,'long_name','Sea Water Temperature')
netcdf.putAtt(ncid,temp_ID,'coordinates','time latitude longitude pressure')
netcdf.putAtt(ncid,temp_ID,'standard_name','sea_water_temperature')
netcdf.putAtt(ncid,temp_ID,'units','degrees_C')
netcdf.putAtt(ncid,temp_ID,'valid_min','-2')
netcdf.putAtt(ncid,temp_ID,'valid_max','30')
netcdf.putAtt(ncid,temp_ID,'coverage_content_type','physicalMeasurement')


netcdf.putAtt(ncid,ID_ID,'long_name','Data Set ID')
netcdf.putAtt(ncid,ID_ID,'coordinates','time latitude longitude pressure')
netcdf.putAtt(ncid,ID_ID,'meanings','1 = Shipboard CTD, 2 - 11 = NAVOgliders, 12 - 16 = Saildrones, 17 = TSG, 18 - 20 = Wavegliders, 21 = EcoCTD')
netcdf.putAtt(ncid,ID_ID,'coverage_content_type','referenceInformation')

%A final netcdf.endDef(ncid) to seal and changes to the metadata. 
netcdf.endDef(ncid)
%Last thing is to close the file with netcdf.close. This one is important
%because if you forget to do it your files will get corrupted and you won't
%realize until it is too late. (has happened to me many terrible times) 
netcdf.close(ncid)


%Display the file 
ncdisp("combined_data.nc")