#' Crops a raster and returns a smaller square raster
#'
#' @param raster_input a raster
#' @param lat decimal latitude of the centre of the cropped square
#' @param long decimal longitude of the centre of the cropped square
#' @param square_km length of one side of the square in km
#' @param increase_resolution optional multiplier to increase number of cells in the raster. Default = 1.
#'
#' @return cropped raster
#'
#' @examples
#' crop_raster_square(a_raster, 54.4282623, -2.9787427, square_km = 10)
#' @export
crop_raster_square <- function(raster_input, lat, long, square_km, increase_resolution = 1){
  #create point
  bounding_box <- sp::SpatialPoints(cbind(long, lat, square_km), proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  #Transform to be able to buffer
  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

  #create buffer square
  bounding_shape <- rgeos::gBuffer(bounding_box, width = bounding_box$square_km * 1000, quadsegs=1, capStyle="SQUARE")

  #reproject to match raster
  bounding_shape <- sp::spTransform(bounding_shape, sp::CRS(as.character(raster::crs(raster_input))))

  raster_crop <- raster::crop(raster_input, bounding_shape)


  # Check that the resulting raster is square (identical lat and long resolution) and resample if it isn't. Needed for NASA ASTER data and maybe others.
  square_error <- nrow(raster_crop) / ncol(raster_crop)

  if(square_error != 1){

    max_edge <- max(c(nrow(raster_crop), ncol(raster_crop)))

    template <- raster(extent(raster_crop), crs = crs(raster_crop), nrow = max_edge, ncol = max_edge)

    raster_crop <- raster::resample(raster_crop, template)

  }


  raster_crop <- raster::disaggregate(raster_crop, increase_resolution, method = 'bilinear')

  return(raster_crop)
}
