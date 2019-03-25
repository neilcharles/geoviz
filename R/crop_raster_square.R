#' Crops a raster and returns a smaller square raster
#'
#' @param rasterIn a raster
#' @param lat WGS84 latitude of the centre of the cropped square
#' @param long WGS84 longitude of the centre of the cropped square
#' @param square_km length of one side of the square in km
#' @param increase_resolution optional multiplier to increase number of cells in the raster
#'
#' @return A cropped raster
#'
#' @examples
#' crop_raster_square(example_raster(), lat = 54.513293, long = -3.045598, square_km = 0.01)
#' @export
crop_raster_square <- function(rasterIn, lat, long, square_km, increase_resolution = 1){

  bounding_shape <- square_bounding_box(lat, long, square_km)

  bounding_shape <- sp::spTransform(bounding_shape, sp::CRS(as.character(raster::crs(rasterIn))))

  raster_crop <- raster::crop(rasterIn, bounding_shape)

  # Check that the resulting raster is square (identical lat and long resolution) and resample if it isn't. Needed for NASA ASTER data and maybe others.
  square_error <- nrow(raster_crop) / ncol(raster_crop)

  if(square_error != 1){

    max_edge <- max(c(nrow(raster_crop), ncol(raster_crop)))

    template <- raster::raster(raster::extent(raster_crop), crs = raster::crs(raster_crop), nrow = max_edge, ncol = max_edge)

    raster_crop <- raster::resample(raster_crop, template)

  }

  if(increase_resolution > 1){
    raster_crop <- raster::disaggregate(raster_crop, increase_resolution, method = 'bilinear')
  }

  return(raster_crop)
}
