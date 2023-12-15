#! /bin/bash
#https://ecco.jpl.nasa.gov/drive/files/ECCO2/C1440_LLC2160/SSS/SSS_20200120T000000.nc

fname1="https://ecco.jpl.nasa.gov/drive/files/ECCO2/C1440_LLC2160/SSS/SSS_"
fname2="T"
fname3="0000.nc"
for year in {2020..2021}
#for year in 2020
do
        for month in 01 02 03 04 05 06 07 08 09 10 11 12
        #for month in 02
        do
                for day in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
                #for day in 01
                do
                        #for hour in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
                        for hour in 12
                        do
                                fname=$fname1$year$month$day$fname2$hour$fname3
                                wget $fname --user=binghamf --password=cCfM6lWJ0tkZ3PPKc34
                                echo $fname
                        done
                done
        done
done

