#' Stitches together DEFRA Lidar files and saves as a single large raster
#' Requires a target directory of LIDAR zip files.
#'
#' @param lidar_path directory containing defra lidar zip files
#' @param raster_output_file path and filename for the merged raster. End in ".raster" to save in default R Raster format (.grd)
#'
#' @return TRUE
#'
#' @examples
#' mosaic_defra_lidar("path/to/grid/zip_files/", "output/file.raster")
#' @export
mosaic_defra_lidar <- function(lidar_path, raster_output_file = "mosaic_uk_grid.raster"){

  if(substr(lidar_path, nchar(lidar_path), nchar(lidar_path)) != "/"){
    lidar_path <- glue::glue("{lidar_path}/")
  }

  message("Unzipping DEM files...")

  lidar_zip_files <- tibble::tibble(zip_files = list.files(lidar_path, ".*.zip")) %>%
    dplyr::pull("zip_files") %>%
    purrr::walk(.f = ~  unzip(glue::glue("{lidar_path}{.x}"), exdir = "unzip-asc"))


  grid_files <- list.files("unzip-asc", ".*.asc")

  #Load all terrain files in input directory
  raster_layers <- tibble::tibble(filename = grid_files)


  message("Merging DEM files...")

  #Intialise a raster to merge in the rest of the files one at a time. Can't do it all at once due to memory issues.
  raster_mosaic <- raster::raster(rgdal::readGDAL(glue::glue("unzip-asc/{raster_layers$filename[1]}")))

  #Merge layers one at a time
  for(i in 2:nrow(raster_layers)){
    new_raster <- raster::raster(rgdal::readGDAL(glue::glue("unzip-asc/{raster_layers$filename[i]}")))

    raster_mosaic <- raster::mosaic(raster_mosaic, new_raster, fun = "mean")

  }

  unlink("unzip-asc", recursive = TRUE)  #kill the temp directory containing .asc files

  message("Projecting raster...")

  raster::crs(raster_mosaic) <- "+init=epsg:27700"

  raster_mosaic = raster::projectRaster(raster_mosaic, crs = "+proj=longlat +datum=WGS84 +no_defs")

  raster::writeRaster(raster_mosaic, raster_output_file, overwrite = TRUE)

  message("Done")

  return(TRUE)

}
