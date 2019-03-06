#' Stitches together ASTER GDEM TIF files and saves as a single large raster
#' Requires a target directory of ASTER zip files. Effecively a duplicate of mosaic_uk_grid() with a few tweaks.
#'
#' @param aster_path directory containing OS Terrain 50 'GRID' files
#' @param raster_output_file path and filename for the merged raster. End in ".raster" to save in default R Raster format (.grd)
#'
#' @return TRUE
#'
#' @examples
#' mosaic_ASTER("path/to/grid/zip_files/", "output/file.raster")
#' @export
mosaic_ASTER <- function(aster_path, raster_output_file = "mosaic_ASTER.raster"){

  if(substr(aster_path, nchar(aster_path), nchar(aster_path)) != "/"){
    aster_path <- glue::glue("{aster_path}/")
  }

  read_from_zip <- function(file_id){

    file_id_u <- stringr::str_replace(file_id, ".zip", "_dem.tif")

    r <- raster::raster(rgdal::readGDAL(
      utils::unzip(
        glue::glue("{aster_path}{file_id}"),
        glue::glue("{file_id_u}")
      )
    ))

    file.remove(glue::glue("{file_id_u}"))

    return(r)

  }

  grid_files <- list.files(aster_path, ".*ASTGTM.*.zip$", recursive = TRUE, include.dirs = TRUE)

  #Load all terrain files in input directory
  raster_layers <- tibble::tibble(filename = grid_files)

  #Intialise a raster to merge in the rest of the files one at a time. Can't do it all at once due to memory issues.
  raster_mosaic <- read_from_zip(raster_layers$filename[1])

  #Merge layers one at a time
  for(i in 2:nrow(raster_layers)){
    new_raster <- read_from_zip(raster_layers$filename[i])

    raster_mosaic <- raster::mosaic(raster_mosaic, new_raster, fun = "mean")

  }

  raster::crs(raster_mosaic) <- "+init=epsg:4326"

  raster_mosaic = raster::projectRaster(raster_mosaic, crs = "+proj=longlat +datum=WGS84 +no_defs")

  raster::writeRaster(raster_mosaic, raster_output_file, overwrite = TRUE)

  return(TRUE)

}
