#' Stitches together OS Terrain 50 'GRID' files and saves as a single large raster
#' Requires a target directory of 'GRID' zip files.
#'
#' @param os50_path directory containing OS Terrain 50 'GRID' files
#' @param raster_output_file path and filename for the merged raster. End in ".raster" to save in default R Raster format (.grd)
#'
#' @return TRUE
#'
#' @examples
#' \donttest{
#' mosaic_uk_grid("path/to/grid/zip_files/", "output/file.raster")
#' }
#' @export
mosaic_uk_grid <- function(os50_path, raster_output_file = "mosaic_uk_grid.raster"){

  if(substr(os50_path, nchar(os50_path), nchar(os50_path)) != "/"){
    os50_path <- glue::glue("{os50_path}/")
  }

  read_from_zip <- function(file_id){
    file_id_u <- toupper(substr(file_id, 4, 7))

    r <- raster::raster(rgdal::readGDAL(
      utils::unzip(
        glue::glue("{os50_path}{file_id}"),
        glue::glue("{file_id_u}.asc")
      )
    ))

    file.remove(glue::glue("{file_id_u}.asc"))

    return(r)

  }

  grid_files <- list.files(os50_path, ".*OST50GRID.*", recursive = TRUE, include.dirs = TRUE)

  #Load all terrain files in input directory
  raster_layers <- tibble::tibble(filename = grid_files)


  #Intialise a raster to merge in the rest of the files one at a time. Can't do it all at once due to memory issues.
  raster_mosaic <- read_from_zip(raster_layers$filename[1])

  #Merge layers one at a time
  for(i in 2:nrow(raster_layers)){
    new_raster <- read_from_zip(raster_layers$filename[i])

    raster_mosaic <- raster::mosaic(raster_mosaic, new_raster, fun = "mean")

  }

  raster::crs(raster_mosaic) <- "+init=epsg:27700"

  raster_mosaic = raster::projectRaster(raster_mosaic, crs = "+proj=longlat +datum=WGS84 +no_defs")

  raster::writeRaster(raster_mosaic, raster_output_file, overwrite = TRUE)

  return(TRUE)

}
