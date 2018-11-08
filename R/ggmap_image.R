#' Gets a ggmap to overlay a rayshader scene and returns a raster
#'
#' @param raster_input a raster to use for the dimensions of the overlay
#' @param use_bbox Boolean. If TRUE, attempt to draw a map using the bounding box of raster_input. If FALSE, use the centre of raster_input and a zoom level (use ... to specify zoom = ).
#' ggmap's attempt to fit Google maps will sometimes return a map that is too small, in which case set use_bbox = FALSE and a specify a zoom level that will cover your raster.
#' @param ... Additional parameters to pass to ggmap::get_map() e.g. maptype, source, zoom, color
#'
#' @return a png image to overlay a rayshader scene
#'
#' @examples
#' ggmap_image(a_raster, maptype = "Stamen", zoom = 11, color = "bw")
#'
#' @export
ggmap_image <- function(raster_input, use_bbox = TRUE, ...){

  #Work out the bounding box for the raster and convert it to ggmap projection
  bounding_box <- as(extent(raster_input), "SpatialPolygons")

  sp::proj4string(bounding_box) <- as.character(raster::crs(raster_input))

  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  xt_scene <- raster::extent(bounding_box)

  #Get ggmap
  if(use_bbox){
    raw_ggmap <- ggmap::get_map(c(xt_scene@xmin, xt_scene@ymin, xt_scene@xmax, xt_scene@ymax), ...)
  } else {
    raw_ggmap <- ggmap::get_map(c(mean(c(xt_scene@xmin, xt_scene@xmax)), mean(c(xt_scene@ymin, xt_scene@ymax))), ...)
  }

  #Convert the ggmap to a raster and project it to match raster_input
  ggmap_raster <- ggmap_to_raster(raw_ggmap)

  ggmap_raster <- raster::projectRaster(ggmap_raster, crs = as.character(raster::crs(raster_input)))

  #Resample ggmap to match the dimensions of raster_input
  ggmap_crop <- raster::resample(ggmap_raster, raster_input)

  rgdal::writeGDAL(as(ggmap_crop, "SpatialGridDataFrame"), "map_image.png", drivername = "PNG", type = "Byte")

  map_image <- png::readPNG("map_image.png")

  file.remove("map_image.png")

  #add an alpha layer for ease of overlaying in rayshader
  alpha_layer <- matrix(1, nrow = dim(map_image)[1], ncol = dim(map_image)[2])

  map_image <- abind::abind(map_image, alpha_layer)

  return(map_image)

}
