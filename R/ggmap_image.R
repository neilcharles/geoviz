#' Gets a ggmap to overlay a rayshader scene and returns a raster
#'
#' @param raster_input a raster to use for the dimensions of the overlay
#' @param ... Additional parameters to pass to ggmap::get_map() e.g. maptype, source, zoom, color
#'
#' @return a png image to overlay a rayshader scene
#'
#' @examples
#' ggmap_image(a_raster, maptype = "Stamen", zoom = 11, color = "bw")
#'
#' @export
ggmap_image <- function(raster_input, ...){

  xt_scene <- raster::extent(raster_crop)

  raw_ggmap <- ggmap::get_map(c(xt_scene@xmin, xt_scene@ymin, xt_scene@xmax, xt_scene@ymax), ...)

  ggmap_raster <- ggmap_to_raster(raw_ggmap)

  ggmap_raster <- raster::projectRaster(ggmap_raster, crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

  ggmap_crop <- raster::resample(ggmap_raster, raster_input)

  rgdal::writeGDAL(as(ggmap_crop, "SpatialGridDataFrame"), "map_image.png", drivername = "PNG", type = "Byte")

  map_image <- png::readPNG("map_image.png")

  file.remove("map_image.png")

  #add an alpha layer for ease of overlaying in rayshader
  alpha_layer <- matrix(1, nrow = dim(map_image)[1], ncol = dim(map_image)[2])

  map_image <- abind::abind(map_image, alpha_layer)

  return(map_image)

}
