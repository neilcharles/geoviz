#' Creates a square raster centred on any lat long point, or a rectangular raster surrounding a set of lat long points from 'Mapbox', 'Mapzen' or 'Stamen' Maps using the 'slippymath' package
#'
#' @param lat WGS84 latitude. Either a single point to use as the centre for a \code{square_km} sized raster, or a vector of track points
#' @param long WGS84 longitude. Either a single point to use as the centre for a \code{square_km} sized raster, or a vector of track points
#' @param square_km length of one edge the required square area, in km. Ignored if lat and long have length > 1
#' @param width_buffer If lat and long have length > 1, used as buffer distance around the provided points in km
#' @param image_source Source for the overlay image. Valid entries are "mapbox", "mapzen", "stamen".
#' @param image_type The type of overlay to request. "satellite", "mapbox-streets-v8", "mapbox-terrain-v2", "mapbox-traffic-v1", "terrain-rgb", "mapbox-incidents-v1" (mapbox), "dem" (mapzen) or "watercolor", "toner", "terrain" (stamen)
#' @param max_tiles Maximum number of tiles to be requested by 'slippymath'
#' @param api_key API key (required for 'mapbox')
#'
#' @return a rasterBrick image
#'
#' @examples
#' lat <- 54.4502651
#' long <- -3.1767946
#' square_km <- 1
#'
#' overlay_image <- slippy_raster(lat = lat,
#'   long = long,
#'   square_km = square_km,
#'   image_source = "stamen",
#'   image_type = "watercolor",
#'   max_tiles = 5)
#' @export
slippy_raster <- function(lat, long, square_km, width_buffer = 1, image_source = "stamen", image_type = "watercolor", max_tiles = 10, api_key){

  if(length(lat) != length(long)){
    stop("lengths of lat and long do not match")
  }

  #Calc bounding box
  if(length(lat)==1){
    bounding_box <- square_bounding_box(lat, long, square_km) #single point bounding box
  } else {
    bounding_box <- track_bounding_box(lat, long, width_buffer)
  }

  #Request slippy map
  raster_out <- get_slippy_map(bounding_box, image_source = image_source, image_type = image_type, max_tiles = max_tiles, api_key = api_key)

  return(raster_out)
}
