#' Crops a raster into a rectangle surrounding a set of lat long points
#'
#' @param raster_input a raster
#' @param lat_points a vector of WGS84 latitudes
#' @param long_points a vector of WGS84 longitudes
#' @param width_buffer buffer distance around the provided points in km
#' @param increase_resolution optional multiplier to increase number of cells in the raster. Default = 1.
#'
#' @return cropped raster
#'
#' @examples
#' crop_raster_track(example_raster(), example_igc()$lat, example_igc()$long)
#' @export
crop_raster_track <- function(raster_input, lat_points, long_points, width_buffer = 1, increase_resolution = 1){

  bounding_shape <- track_bounding_box(lat_points, long_points, width_buffer)

  #Convert to match raster projection and crop
  bounding_shape <- sp::spTransform(bounding_shape, sp::CRS(as.character(raster::crs(raster_input))))

  raster_crop <- raster::crop(raster_input, bounding_shape)

  raster_crop <- raster::disaggregate(raster_crop, increase_resolution,
                                      method = "bilinear")

  return(raster_crop)
}
