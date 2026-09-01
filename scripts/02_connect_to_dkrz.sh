#!/bin/bash

# This script connects to the DKRZ server using SSH and downloads data for specified models and scenarios.
# Ensure you have the correct credentials before running this script.

ssh b381132@levante.dkrz.de

# Dowload IPSL historic data

# RUN THIS ON YOUR COMPUTER, NOT LOGGED IN THE SERVER

rsync -avz --progress \
  --include='*/' \
  --include='*uo*30arcmin*1850_2014.nc' \
  --include='*vo*30arcmin*1850_2014.nc' \
  --exclude='*' \
  b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/historical/IPSL-CM6A-LR/ \
  /Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl-cm6a-lr/historical/

  
# Tranfer new data from Mathias
  
rsync -avz --progress \
  --include='*/' \
  --include='*surf*30arcmin*2015_2100.nc' \
  --include='*bot*30arcmin*2015_2100.nc' \
  --include='*tob*30arcmin*2015_2100.nc' \
  --include='*tos*30arcmin*2015_2100.nc' \
  --include='*siconc*30arcmin*2015_2100.nc' \
  --include='*intpp*30arcmin*2015_2100.nc' \
  --include='*intppdiat*30arcmin*2015_2100.nc' \
  --include='*uo*30arcmin*2015_2100.nc' \
  --include='*vo*30arcmin*2015_2100.nc' \
  --include='*uo*30arcmin*2101_2300.nc' \
  --include='*vo*30arcmin*2101_2300.nc' \
  --exclude='*' \
  b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/ssp126/IPSL-CM6A-LR/ \
  /Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl-cm6a-lr/
  
  
  
  rsync -avz --progress \
  --include='*/' \
  --include='*vo*30arcmin*2101_2300.nc' \
  --exclude='*' \
  b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/ssp126/IPSL-CM6A-LR/ \
  /Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl-cm6a-lr/


