#!/bin/bash
#SBATCH --job-name=ADRDisp
#SBATCH --account=def-wailung
#SBATCH -N 1 	#Nodes
#SBATCH -N 1	#CPU count
#SBATCH --mem-per-cpu=900M
#SBATCH -t 01-00:00:00
#SBATCH --mail-user=j.palacios@oceans.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH --array=10-11
#SBATCH --output=slurm_out/netcdfArray-%A-%a.out
#SBATCH --error=slurm_out/netcdfArray-%A-%a.err

# Model settings ============================================
CCSc=$(awk '$1 == "CCSc" {print $2}' settings.txt)
runName=$(awk '$1 == "rpath" {print $2}' settings.txt)
SppListName=$(awk '$1 == "rsfile" {print $2}' settings.txt)

# Extract environmental data ============================================
Root=~/projects/def-wailung/Data/Climate/fishmip2300/${CCSc}

cd $SLURM_TMPDIR
echo "Extracting environmental data"
# TODO -- fix ESM_Process output names to include C6 etc. (better for traceability)
cp ${Root}/SST_${CCSc}_y.nc ./
cp ${Root}/bot_temp_${CCSc}_y.nc ./
cp ${Root}/AdvectionU_${CCSc}_y.nc ./
cp ${Root}/AdvectionV_${CCSc}_y.nc ./
cp ${Root}/htotal_btm_${CCSc}_y.nc ./
cp ${Root}/htotal_surf_${CCSc}_y.nc ./
cp ${Root}/O2_btm_${CCSc}_y.nc ./
cp ${Root}/O2_surf_${CCSc}_y.nc ./
cp ${Root}/Salinity_btm_${CCSc}_y.nc ./
cp ${Root}/Salinity_surf_${CCSc}_y.nc ./
cp ${Root}/IceExt_${CCSc}_y.nc ./
cp ${Root}/totalphy2_${CCSc}_y.nc ./
echo "Environmental data extracted"

# Run DBEM ============================================
cd $SLURM_SUBMIT_DIR
echo "Current working directory is `pwd`"
echo "Starting run at:$(date)"
echo “Starting task: $SLURM_ARRAY_TASK_ID”

export OMP_NUM_THREADS=1
# ../../dbem_scripts/DBEM_v2_y_netCDF $SLURM_TMPDIR $SLURM_ARRAY_TASK_ID
# Central DBEM script with netCDF support
~/projects/def-wailung/jepa/dbem/dbem_scripts/DBEM_v3_y $SLURM_TMPDIR $SLURM_ARRAY_TASK_ID
echo "Program $SLURM_JOB_NAME finished with exit code $? at: $(date)"

# Compress raw DBEM outputs ============================================
# Make directory to store results
mkdir -p ~/scratch/Results/$runName
mkdir -p ~/scratch/Results/$runName/netcdfs

echo 'Compressing DBEM outputs'
cd $SLURM_TMPDIR
tar --use-compress-program="pigz -p 4" -cf ${CCSc}_${runName}_${SppListName}${SLURM_ARRAY_TASK_ID}_netcdf.tar.gz $runName
echo "Compressed as ${CCSc}_${runName}_${SppListName}${SLURM_ARRAY_TASK_ID}_netcdf.tar.gz"

mv ${CCSc}_${runName}_${SppListName}${SLURM_ARRAY_TASK_ID}_netcdf.tar.gz ~/scratch/Results/$runName/ #move to scratch

# Create netCDFs of output =========================================
cd $SLURM_SUBMIT_DIR
echo 'Creating netCDF'
module load  StdEnv/2020  gcc/9.3.0  udunits/2.2.28  gdal/3.5.1  netcdf/4.7.4 r/4.2.2
export R_LIBS=~/local/esm_process_libs/ ## TODO create the env for proper aggregation
Rscript ../aggregate_dbem/dbem_out_netcdf.R
echo 'Finished!'
