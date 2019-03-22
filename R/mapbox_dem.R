#' Gets Digital Elevation Model (DEM) data from mapbox
#'
#' @param lat WGS84 latitude
#' @param long WGS84 longitude
#' @param square_km length of one edge the required square area, in km
#' @param api_key Mapbox API key
#'
#' @return a raster with values corresponding to terrain height in metres
#'
#' @examples
#' \dontrun{
#' mapbox_key = "YOUR_MAPBOX_API_KEY"
#'
#' lat = 54.4502651
#' long = -3.1767946
#' square_km = 20
#'
#' dem <- mapbox_dem(lat, long, square_km, mapbox_key)
#'
#' }
#' @export
mapbox_dem <- function(lat, long, square_km, api_key){

  mapbox_terrain <-
    slippy_raster(
      lat,
      long,
      square_km,
      image_source = "mapbox",
      image_type = "terrain-rgb",
      resolution = 1000,
      max_tiles = 30,
      api_key = api_key
    )

  DEM = -10000 + ((
    raster::raster(mapbox_terrain, layer = 1) * 256 * 256 +
      raster::raster(mapbox_terrain, layer = 2) * 256 +
      raster::raster(mapbox_terrain, layer = 3)) * 0.1)

  return(DEM)

}
