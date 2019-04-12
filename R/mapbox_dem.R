#' Gets Digital Elevation Model (DEM) data from 'mapbox'
#'
#' @param lat WGS84 latitude. Either a single point to use as the centre for a \code{square_km} sized raster, or a vector of track points
#' @param long WGS84 longitude. Either a single point to use as the centre for a \code{square_km} sized raster, or a vector of track points
#' @param square_km length of one edge the required square area, in km. Ignored if lat and long have length > 1
#' @param width_buffer If lat and long have length > 1, used as buffer distance around the provided points in km
#' @param max_tiles maximum number of map tiles to request. More tiles will give higher resolution scenes but take longer to download. Note that very small numbers of tiles may result in a scene that is not square.
#' @param api_key 'Mapbox' API key
#'
#' @return a raster with values corresponding to terrain height in metres
#'
#' @examples
#' \dontrun{
#' #NOT RUN
#' #mapbox_dem() requires a 'mapbox' API key
#'
#' mapbox_key = "YOUR_MAPBOX_API_KEY"
#'
#' lat = 54.4502651
#' long = -3.1767946
#' square_km = 20
#'
#' dem <- mapbox_dem(lat, long, square_km, api_key = mapbox_key)
#'
#' }
#' @export
mapbox_dem <- function(lat, long, square_km, width_buffer = 1, max_tiles, api_key){

  mapbox_terrain <-
    slippy_raster(
      lat,
      long,
      square_km,
      image_source = "mapbox",
      image_type = "terrain-rgb",
      max_tiles = max_tiles,
      api_key = api_key
    )

  DEM = -10000 + ((
    raster::raster(mapbox_terrain, layer = 1) * 256 * 256 +
      raster::raster(mapbox_terrain, layer = 2) * 256 +
      raster::raster(mapbox_terrain, layer = 3)) * 0.1)

  return(DEM)

}
