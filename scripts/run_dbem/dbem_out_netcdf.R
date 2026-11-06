## This script takes a DBEM run on 0.5 degree grid and converts the annual .txt file into a netCDF. 
## Each layer represents a timestep and one layer is a 2D grid

# Load packages ----------------------------------
library(ncdf4)
library(here)
here::i_am('scripts/run_dbem/dbem_out_netcdf.R')

# Load global data ------------------------------
dbem_grid <- read.csv('~/projects/def-wailung/Data/Environment/Lat_Lon.txt', header = FALSE)
colnames(dbem_grid) <- c('index', 'lat', 'lon')

dbem_settings <- read.table(here('scripts/run_dbem/settings.txt'))
run_name <- dbem_settings$V2[dbem_settings$V1=='rpath']
CCSc <- dbem_settings$V2[dbem_settings$V1=='CCSc']
SSP <- dbem_settings$V2[dbem_settings$V1=='SSP']
FHS <- dbem_settings$V2[dbem_settings$V1=='FHS']
FEEZ <- dbem_settings$V2[dbem_settings$V1=='FEEZ']
MPA_scen <- dbem_settings$V2[dbem_settings$V1=='MPApath']

#dbem_var <- 'Catch' # 'Catch or Abd'

# List species to run
spplist <- list.files(file.path(Sys.getenv("SLURM_TMPDIR"), run_name))

create_dbem_nc <- function(sp, dbem_var, txt_files, dbem_settings, dbem_grid){
  # Function to create a netcdf of DBEM outputs
  # IN
    # sp: species ID (as str)
    # dbem_var: variable to process (Catch or Abd)
    # txt_files: list of .txt files to process
    # dbem_settings: settings used in DBEM run (as dataframe)
    # dbem_grid: dbem lat lon grid

  # Extract metadata from dbem settings
  run_name <- dbem_settings$V2[dbem_settings$V1=='rpath']
  CCSc <- dbem_settings$V2[dbem_settings$V1=='CCSc']
  SSP <- dbem_settings$V2[dbem_settings$V1=='SSP']
  FHS <- dbem_settings$V2[dbem_settings$V1=='FHS']
  FEEZ <- dbem_settings$V2[dbem_settings$V1=='FEEZ']
  MPA_scen <- dbem_settings$V2[dbem_settings$V1=='MPApath']
  
  FHS_str <- gsub("\\.", "-", sprintf("%.2f", as.numeric(FHS)))
  FEEZ_str <- gsub("\\.", "-", sprintf("%.2f", as.numeric(FEEZ)))

  # Output file path 
  out_name <-  paste0(sp,'_' ,dbem_var, '_', CCSc, '_', SSP, '_FHS_', FHS_str,'_FEEZ_', FEEZ_str, '_',MPA_scen,'.nc')
  output_nc_file <- file.path('~/scratch/Results', run_name, 'netcdfs', out_name)
  missing_value <- NA

  # DBEM lat/lon 0.5° x 0.5° grid 
  lon <- seq(-179.75, 179.75, by = 0.5)
  lat <- seq(89.75, -89.75, by = -0.5)

  # Create the netCDF
  # Set dimensions 
  lon_dim <- ncdim_def(name = "lon", units = "degrees_east", vals = lon, longname = "Longitude")
  lat_dim <- ncdim_def(name = "lat", units = "degrees_north", vals = lat, longname = "Latitude")
  time_dim <- ncdim_def(name = "time_dim", units = "time_steps", vals = seq_along(txt_files), unlim = TRUE)

  # Define data variables
  var <- ncvar_def(name = dbem_var,
                  units = '',
                  dim = list(lon_dim, lat_dim, time_dim),
                  missval = missing_value)

  time_var <- ncvar_def(name = "time",
                        units = 'year',
                        dim = list(time_dim),
                        longname = "Time")

  # Create the netCDF file
  nc <- nc_create(output_nc_file, list(var, time_var))

  # Loop through each file, read data, and write to netCDF
  for (i in seq_along(txt_files)) {
    # Read data
    variable_values <- read.table(txt_files[i])
    colnames(variable_values) <- c('index', 'value')
    # Merge to dbem grid
    variable_values <- merge(dbem_grid, variable_values, all.x = TRUE)
    
    # Convert the linear data into a 2D grid
    variable_grid <- matrix(variable_values$value, nrow = length(lat), ncol = length(lon), byrow = FALSE)
    # Replace missing values
    variable_grid[variable_grid == missing_value] <- NA
    
    # Write the grid to the netCDF file at the current time index
    ncvar_put(nc, var, variable_grid, start = c(1, 1, i), count = c(-1, -1, 1))
    # Extract time value 
    t <- as.numeric(sub(".*(\\d{4})\\.txt$", "\\1", basename(txt_files[i])))
    ncvar_put(nc, time_var, t, start = i, count = 1)
  }

  # Read species metadata
  tax_info <- read.table(paste0('~/projects/def-wailung/Data/Species/TaxonDataC0/', sp, '.txt'))
  
  # Attach metadata to file
  ncatt_put(nc, 0, 'Description', dbem_var)
  ncatt_put(nc, 0, 'TaxonID', sp)
  ncatt_put(nc, 0, 'TaxonName', tax_info$V2[tax_info$V1 == 'TaxonName'])
  ncatt_put(nc, 0, 'CCSc', dbem_settings$V2[dbem_settings$V1=='CCSc'])
  ncatt_put(nc, 0, 'SSP', dbem_settings$V2[dbem_settings$V1=='SSP'])
  ncatt_put(nc, 0, 'DemPel', tax_info$V2[tax_info$V1 == 'DemPel'])
  ncatt_put(nc, 0, 'FHS', FHS)
  ncatt_put(nc, 0, 'FEEZ', FEEZ)
  ncatt_put(nc, 0, 'MPA_Scenario', MPA_scen)
  ncatt_put(nc, 0, 'Creation_Date', as.character(Sys.Date()))

  # Close the netCDF file
  nc_close(nc)
}

for (sp in spplist){
  print(sp)
  # Run for Abd
  dbem_var <- 'Abd'
  txt_files <- list.files(file.path(Sys.getenv("SLURM_TMPDIR"), run_name, sp), pattern = dbem_var, full.names = TRUE)
  if (length(txt_files) != 0){
    create_dbem_nc(sp = sp,
                  dbem_var = dbem_var,
                  txt_files = txt_files,
                  dbem_settings = dbem_settings,
                  dbem_grid = dbem_grid)
  } else {
    print(paste('No files for', sp, dbem_var))
  }
  # Run for Catch (only if there is catch)
  if ((as.numeric(FHS) != 0) | (as.numeric(FEEZ) != 0)){
    dbem_var <- 'Catch'
    txt_files <- list.files(file.path(Sys.getenv("SLURM_TMPDIR"), run_name, sp), pattern = dbem_var, full.names = TRUE)
      if (length(txt_files) != 0){
      create_dbem_nc(sp = sp,
                    dbem_var = dbem_var,
                    txt_files = txt_files,
                    dbem_settings = dbem_settings,
                    dbem_grid = dbem_grid)
    } else {
      print(paste('No files for', sp, dbem_var))
    }
  } else {cat 
    print('No fishing in this simulation')
  }

}