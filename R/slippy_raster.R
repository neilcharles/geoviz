#' Creates an overlay image from various sources using Miles McBain's slippymath
#'
#' @param lat WGS84 latitude
#' @param long WGS84 longitude
#' @param square_km length of one edge the required square area, in km
#' @param image_source Source for the overlay image. Valid entries are "mapbox", "stamen".
#' @param image_type The type of overlay to request. "satellite", "mapbox-streets-v8", "mapbox-terrain-v2", "mapbox-traffic-v1", "terrain-rgb", "mapbox-incidents-v1" (mapbox) or "watercolor", "toner", "terrain" (stamen)
#' @param resolution width and height (cell count) of the returned raster
#' @param max_tiles Maximum number of tiles to be requested by slippymath
#' @param api_key API key (required for mapbox)
#'
#' @return a rasterBrick image
#'
#' @examples
#' \donttest{
#' #NEEDS EXAMPLE
#' }
#' @export
slippy_raster <- function(lat, long, square_km, image_source = "stamen", image_type = "watercolor", resolution = 1000, max_tiles = 30, api_key){

  #Calc bounding box
  bounding_box <- square_bounding_box(lat, long, square_km)

  #Request slippy map
  raster_out <- get_slippy_map(bounding_box, image_source = image_source, image_type = image_type, max_tiles = max_tiles, api_key = api_key)

  raster_out <- raster::projectRaster(raster_out, crs = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  #Make a raster to overlay slippy map onto
  overlay_raster <- raster::raster(raster::extent(bounding_box), ncol = resolution, nrow = resolution, crs = raster::crs(bounding_box))

  raster_out <- raster::resample(raster_out, overlay_raster)

  return(raster_out)
}