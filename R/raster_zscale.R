#' Calculates the zscale of a raster Digital Elevation Model for rayshader
#'
#' @param raster A raster object of elevation data values
#' @param height_units Elevation units of the raster, c("m", "feet")
#'
#' @return a number to be used as zscale in rayshader::plot_3d()
#'
#' @examples
#' raster_zscale(example_raster)
#'
#' @export
raster_zscale <- function(raster, height_units = "m"){

  raster_wgs84 <- raster::projectRaster(raster, crs = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  scaling <- raster::pointDistance(
    c(
      raster::extent(raster_wgs84)@xmin,
      raster::extent(raster_wgs84)@ymin
    ),
    c(raster::extent(raster_wgs84)@xmax,
      raster::extent(raster_wgs84)@ymin
    ),
    lonlat = TRUE
  ) / ncol(raster_wgs84)

  if(scaling=="feet"){
    scaling <- scaling * 3.28
  }

  return(scaling)

}
