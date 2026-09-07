#' Determine a standardized output variable name for a FishMIP NetCDF file
#'
#' Identifies the appropriate standardized variable name to use in a merged
#' output NetCDF file. The function uses the input filename for variables whose
#' identity depends on vertical position (surface versus bottom), and uses the
#' NetCDF variable name for variables that are uniquely identifiable from the
#' internal variable name alone.


get_output_varname <- function(path, nc_varname) {
  
  # Filename only, without directory path
  file_name <- basename(path)
  
  # Use filename where location/depth is required
  if (grepl("o2-bot", file_name, fixed = TRUE)) {
    return("O2_btm")
  }
  
  if (grepl("o2-surf", file_name, fixed = TRUE)) {
    return("O2_surf")
  }
  
  if (grepl("so-bot", file_name, fixed = TRUE)) {
    return("Salinity_btm")
  }
  
  if (grepl("so-surf", file_name, fixed = TRUE)) {
    return("Salinity_surf")
  }
  
  if (grepl("ph-bot", file_name, fixed = TRUE)) {
    return("htotal_btm")
  }
  
  if (grepl("ph-surf", file_name, fixed = TRUE)) {
    return("htotal_surf")
  }
  
  # Variables identifiable directly from NetCDF variable name
  var_map <- c(
    "uo"     = "AdvectionU",
    "vo"     = "AdvectionV",
    "tob"    = "bot_temp",
    "tos"    = "SST",
    "siconc" = "IceExt"
  )
  
  if (nc_varname %in% names(var_map)) {
    return(unname(var_map[[nc_varname]]))
  }
  
  stop(
    "Could not determine an output variable name.\n",
    "NetCDF variable: ", nc_varname, "\n",
    "Filename: ", file_name
  )
}
