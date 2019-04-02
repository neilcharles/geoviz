#' Converts WGS84 lat long points into 'rayshader' coordinates. Useful for adding arbitrary points and text to a 'rayshader' scene.
#'
#' @param raster_input a raster
#' @param lat vector of WGS84 latitude points
#' @param long vector of WGS84 longitude points
#'
#' @return A tibble with x,y in 'rayshader' coordinates
#'
#' @examples
#' latlong_to_rayshader_coords(example_raster(), example_igc()$lat, example_igc()$long)
#' @export
latlong_to_rayshader_coords <- function(raster_input, lat, long){

  #Convert the track to spatialpoints in raster_input's projection
  track <- sp::SpatialPoints(cbind(long, lat), proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))
  track <- sp::spTransform(track, sp::CRS(as.character(raster::crs(raster_input))))

  track <- tibble::as.tibble(track@coords)

  lat <- track$lat

  long <- track$long

  #Work out the dimensions of raster_input and map the track onto it
  e <- raster::extent(raster_input)

  cell_size_x <- raster::pointDistance(c(e@xmin, e@ymin),
                                       c(e@xmax, e@ymin), lonlat = FALSE)/ncol(raster_input)

  cell_size_y <- raster::pointDistance(c(e@xmin, e@ymin),
                                       c(e@xmin, e@ymax), lonlat = FALSE)/nrow(raster_input)

  distances_x <- raster::pointDistance(c(e@xmin, e@ymin),
                                       cbind(long, rep(e@ymin, length(long))), lonlat = FALSE)/cell_size_x

  distances_y <- raster::pointDistance(c(e@xmin, e@ymin),
                                       cbind(rep(e@xmin, length(lat)), lat), lonlat = FALSE)/cell_size_y

  tibble::tibble(x = distances_x,
         y = distances_y)

}
