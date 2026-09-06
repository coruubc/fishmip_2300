#!/bin/bash
module load intel/2022.1.0  StdEnv/2020 netcdf-fortran
ifort -qopenmp ../../dbem_scripts/DBEM_v2_y_netCDF.f90 -o ../../dbem_scripts/DBEM_v2_y_netCDF -lnetcdff