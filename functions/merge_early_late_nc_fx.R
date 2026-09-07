
# Merge early historical, late historical, and future NetCDF files into one
# continuous annual time series.
#
# The function reads a common spatial variable from three compatible NetCDF
# files, concatenates their data along the time dimension, and writes a new
# NetCDF file containing the merged data. It retains the longitude and latitude
# coordinates, creates a continuous annual time vector, copies global metadata
# from the early-period file, and assigns a standardized output variable name
# using get_output_varname().
#
# Arguments:
#   path_early  Path to the early historical NetCDF file.
#   path_late   Path to the late historical NetCDF file.
#   path_future Path to the future-scenario NetCDF file.
#   out_dir     Directory in which to save the merged NetCDF file.
#
# Returns:
#   Invisibly returns the path to the newly created merged NetCDF file.


merge_early_late_nc <- function(path_early, path_late, path_future, out_dir) {
  
  # --- Open input files ---
  nc_early  <- nc_open(path_early)
  nc_late   <- nc_open(path_late)
  nc_future <- nc_open(path_future)
  
  # Close inputs even if an error occurs
  on.exit({
    nc_close(nc_early)
    nc_close(nc_late)
    nc_close(nc_future)
  }, add = TRUE)
  
  # --- Read coordinates ---
  lon <- ncvar_get(nc_early, "lon")
  lat <- ncvar_get(nc_early, "lat")
  
  # --- Identify the actual data variable INSIDE the NetCDF ---
  input_varname <- setdiff(
    names(nc_early$var),
    c("lon", "lat", "time", "time_var", "time_dim", "year")
  )[[1]]
  
  if (is.null(input_varname) || length(input_varname) == 0) {
    stop("No suitable data variable found in: ", path_early)
  }
  
  # --- Determine desired variable name using filename + NetCDF variable ---
  output_varname <- get_output_varname(
    path = path_early,
    nc_varname = input_varname
  )
  
  # --- Read each input file using its internal NetCDF variable name ---
  data_early  <- ncvar_get(nc_early, input_varname)
  data_late   <- ncvar_get(nc_late, input_varname)
  data_future <- ncvar_get(nc_future, input_varname)
  
  # --- Join the arrays along the third dimension: time ---
  data_full <- abind(data_early, data_late, data_future, along = 3)
  
  # --- Define the intended annual years ---
  # Change this if your three files do not collectively span 1850–2300.
  time_full <- 1850:2300
  
  if (length(time_full) != dim(data_full)[3]) {
    stop(
      "Time length mismatch.\n",
      "Time vector has ", length(time_full), " years (1850–2300 inclusive),\n",
      "but merged data has ", dim(data_full)[3], " layers.\n",
      "Check the actual temporal coverage of the three source files."
    )
  }
  
  # --- Preserve source data units where possible ---
  input_units <- ncatt_get(
    nc_early,
    input_varname,
    "units"
  )$value
  
  if (is.null(input_units) || is.na(input_units)) {
    input_units <- ""
  }
  
  # --- Define output dimensions ---
  dim_lon <- ncdim_def(
    name = "lon",
    units = "degrees_east",
    vals = lon,
    create_dimvar = TRUE
  )
  
  dim_lat <- ncdim_def(
    name = "lat",
    units = "degrees_north",
    vals = lat,
    create_dimvar = TRUE
  )
  
  dim_time <- ncdim_def(
    name = "time_dim",
    units = "year",
    vals = time_full,
    unlim = TRUE,
    create_dimvar = TRUE
  )
  
  # --- Define output variables ---
  var_time <- ncvar_def(
    name = "time_var",
    units = "year",
    dim = list(dim_time),
    missval = NULL,
    prec = "integer"
  )
  
  # The important part: output_varname is used here
  var_data <- ncvar_def(
    name = output_varname,
    units = input_units,
    dim = list(dim_lon, dim_lat, dim_time),
    missval = -9999,
    longname = output_varname,
    prec = "double"
  )
  
  # --- Construct requested output filename ---
  outname <- paste0(output_varname, "_IPSL2300_y.nc")
  path_merged <- file.path(out_dir, outname)
  
  # --- Create output NetCDF file ---
  nc_out <- nc_create(path_merged, list(var_time, var_data))
  # on.exit(nc_close(nc_out), add = TRUE)
  
  # --- Write data ---
  ncvar_put(nc_out, "time_var", time_full)
  ncvar_put(nc_out, output_varname, data_full)
  
  # --- Copy global attributes ---
  global_attributes <- ncatt_get(nc_early, 0)
  
  for (att_name in names(global_attributes)) {
    ncatt_put(nc_out, 0, att_name, global_attributes[[att_name]])
  }
  
  # --- Record processing history ---
  ncatt_put(
    nc_out,
    0,
    "history",
    paste0(
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      ": merged source files; ",
      "renamed data variable from '", input_varname,
      "' to '", output_varname, "'."
    )
  )
  
  # Explicitly close output before returning
  nc_close(nc_out)
  
  cat(
    "\nMerged successfully\n",
    "Input NetCDF variable: ", input_varname, "\n",
    "Output NetCDF variable: ", output_varname, "\n",
    "Output file: ", path_merged, "\n",
    sep = ""
  )
  
  invisible(path_merged)
}
