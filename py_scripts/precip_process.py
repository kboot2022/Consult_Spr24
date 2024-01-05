# Examine and process .nc precipitation data downloaded from https://www.ncei.noaa.gov/data/nclimgrid-daily/access/grids
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import netCDF4 as nc

path = '/share/bingham/bootk/precip/data/ncdd-202112-grd-scaled.nc'
data = nc.Dataset(path, 'r')
var_names = data.variables
print(var_names)
