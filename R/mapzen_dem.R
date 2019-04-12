#' Gets Digital Elevation Model (DEM) data from 'mapzen' via 'Amazon Public Datasets'
#'
#' @param lat WGS84 latitude
#' @param long WGS84 longitude
#' @param square_km length of one edge the required square area, in km
#' @param max_tiles maximum number of map tiles to request. More tiles will give higher resolution scenes but take longer to download. Note that very small numbers of tiles may result in a scene that is not square.
#'
#' @return a raster with values corresponding to terrain height in metres
#'
#' @examples
#' lat = 54.4502651
#' long = -3.1767946
#' square_km = 10
#'
#' dem <- mapzen_dem(lat, long, square_km)
#' @export
mapzen_dem <- function(lat, long, square_km, max_tiles = 10){

  mapzen_terrain <-
    slippy_raster(
      lat,
      long,
      square_km,
      image_source = "mapzen",
      image_type = "dem",
      max_tiles = max_tiles
    )

  #(red * 256 + green + blue / 256) - 32768

  DEM <-
    (raster::raster(mapzen_terrain, layer = 1) * 256 +
      raster::raster(mapzen_terrain, layer = 2) +
      raster::raster(mapzen_terrain, layer = 3) / 256) - 32768

  return(DEM)

}
