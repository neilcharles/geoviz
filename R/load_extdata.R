#' Returns an example digital elevation model raster file()
#'
#' @return a raster
#'
#' @examples
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
#' igc <- example_igc()
#' @export
example_igc <- function(){
  read_igc(system.file("extdata/example.igc", package = "geoviz"))
}
