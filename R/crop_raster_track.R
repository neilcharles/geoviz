#' Crops a raster into a rectangle surrounding a set of lat long points
#'
#' @param raster_input a raster
#' @param lat_points a vector of decimal latitudes
#' @param long_points a vector of decimal longitudes
#' @param width_bufer buffer distance around the provided points
#' @param increase_resolution optional multiplier to increase number of cells in the raster. Default = 1.
#'
#' @return cropped raster
#'
#' @examples
#' crop_raster_track(a_raster, some_lat_points, some_long_points)
#' @export
crop_raster_track <- function(raster_input, lat_points, long_points, width_buffer = 1, increase_resolution = 1){

  #Make a bounding box around the track points
  bounding_box <- sp::SpatialPoints(cbind(long_points, lat_points),
                                    proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  bounding_box <- as(extent(bounding_box), 'SpatialPolygons')

  sp::proj4string(bounding_box) <- "+proj=longlat +datum=WGS84 +no_defs"

  #Reproject for rgeos
  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

  #Pad a border around the bounding box
  bounding_shape <- rgeos::gBuffer(bounding_box, capStyle = "SQUARE", width = width_buffer * 1000)

  #Convert to match raster projection and crop
  bounding_shape <- sp::spTransform(bounding_shape, sp::CRS(as.character(raster::crs(raster_input))))

  raster_crop <- raster::crop(raster_input, bounding_shape)

  raster_crop <- raster::disaggregate(raster_crop, increase_resolution,
                                      method = "bilinear")

  return(raster_crop)
}
