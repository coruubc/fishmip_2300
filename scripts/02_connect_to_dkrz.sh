#!/bin/bash

# This script connects to the DKRZ server using SSH and downloads data for specified models and scenarios.
# Ensure you have the correct credentials before running this script.

ssh b381132@levante.dkrz.de

# Dowload IPSL ssp 126 data

# Define files to download
#"ipsl-cm6a-lr_r1i1p1f1_ssp126_intpp_30arcmin_global_monthly_2101_2300.nc"
  #"ipsl-cm6a-lr_r1i1p1f1_ssp126_intppdiat_30arcmin_global_monthly_2101_2300.nc"
  #"ipsl-cm6a-lr_r1i1p1f1_ssp126_intppmisc_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_ssp126_intppdiaz_60arcmin_global_monthly_2015_2100.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_o2-bot_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_o2-surf_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_ph-surf_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_siconc_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_so-bot_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_so-surf_30arcmin_global_monthly_2101_2300.nc"
  # "ipsl-cm6a-lr_r1i1p1f1_ssp126_tos_30arcmin_global_monthly_2101_2300.nc"
# "ipsl-cm6a-lr_r1i1p1f1_ssp126_ph-bot_30arcmin_global_monthly_2101_2300.nc"

files=(  
  
  "ipsl-cm6a-lr_r1i1p1f1_ssp126_uo_30arcmin_global_monthly_2101_2300.nc"
"ipsl-cm6a-lr_r1i1p1f1_ssp126_vo_30arcmin_global_monthly_2101_2300.nc"
)


remote_base="/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly"
local_base="/Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl"

for file in "${files[@]}"; do
  scp -r "b381132@levante.dkrz.de:$remote_base/ssp126/IPSL-CM6A-LR/$file" "$local_base/ssp126/"
done

# Note that U and V are missing from the list above as they are needed for the FishMIP 2300 simulations.

# Single file download commands for U and V components
scp -r "b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/ssp126/IPSL-CM6A-LR/ipsl-cm6a-lr_r1i1p1f1_ssp126_uo_30arcmin_global_monthly_2101_2300.nc" "/Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl/ssp126/"

scp -r "b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/ssp126/IPSL-CM6A-LR/ipsl-cm6a-lr_r1i1p1f1_ssp126_vo_30arcmin_global_monthly_2101_2300.nc" "/Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl/ssp126/"


  
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
  --include='*uo*30arcmin*2101_2300.nc' \
  --include='*vo*30arcmin*2001_2300.nc' \
  --exclude='*' \
  b381132@levante.dkrz.de:/work/bb0820/ISIMIP/ISIMIP3b/SecondaryInputData/climate/ocean/uncorrected/global/monthly/ssp126/IPSL-CM6A-LR/ \
  /Volumes/Enterprise/Data/FishMip/fishmip_2300/ipsl-cm6a-lr/


