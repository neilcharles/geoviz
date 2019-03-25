#' Returns an example digital elevation model raster file()
#'
#' @return a raster
#'
#' @examples
#'
#' # Load elevation data describing  a small section of the English Lake District
#' # Source: EU Copernicus https://land.copernicus.eu/terms-of-use
#'
#' example_raster <- example_raster()
#' @export
example_raster <- function(){
  raster::raster(system.file("extdata/example.tif", package = "geoviz"))
}


#' Returns an example IGC file using read_igc()
#'
#' @return a tibble
#'
#' @examples
#'
#' # Loads a paragliding flight GPS track, originally downloaded from xcleague.com
#'
#' igc <- example_igc()
#' @export
example_igc <- function(){
  read_igc(system.file("extdata/example.igc", package = "geoviz"))
}
