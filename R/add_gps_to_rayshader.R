#' Adds a GPS trace to a rayshader scene
#'
#' @param raster_input a raster
#' @param lat vector of decimal latitude points
#' @param long vector of decimal longitude points
#' @param alt vector of altitudes
#'
#' @return Adds GPS trace to the current rayshader scene
#'
#' @examples
#' flight <- read_igc("path/to/igc/file")
#' add_gps_to_rayshader(a_raster, flight$lat, flight$long, flight$altitude)
#' @export
add_gps_to_rayshader <- function(raster_input, lat, long, alt, zscale, line_width = 1.5, colour = "red", alpha = 0.8){

  e <- raster::extent(raster_input)

  cell_size_x <- raster::pointDistance(c(e@xmin, e@ymin), c(e@xmax, e@ymin), lonlat = TRUE) / ncol(raster_input)

  cell_size_y <- raster::pointDistance(c(e@xmin, e@ymin), c(e@xmin, e@ymax), lonlat = TRUE) / nrow(raster_input)

  distances_x <- raster::pointDistance(c(e@xmin, e@ymin), cbind(flight$long, rep(e@ymin, nrow(flight))), lonlat = TRUE) / cell_size_x

  distances_y <- raster::pointDistance(c(e@xmin, e@ymin), cbind(rep(e@xmin, nrow(flight)), flight$lat), lonlat = TRUE) / cell_size_y


  rgl::lines3d(
    distances_x,  #lat
    flight$altitude / zscale,  #alt
    -distances_y,  #long
    color = colour,
    alpha = alpha,
    lwd = line_width
  )

}
