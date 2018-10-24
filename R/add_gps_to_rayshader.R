#' Adds a GPS trace to a rayshader scene
#'
#' @param raster_input a raster
#' @param lat vector of decimal latitude points
#' @param long vector of decimal longitude points
#' @param alt vector of altitudes
#' @param zscale ratio of raster cells to altitude
#' @param line_width line width of the gps trace
#' @param colour colour of the gps trace
#' @param alpha alpha of the gps trace (has no effect if lightsaber = TRUE)
#' @param lightsaber (default = TRUE) gives the GPS trace an inner glow affect
#' @param clamp_to_ground (default = FALSE) clamps the gps trace to ground level + raise_agl
#' @param raise_agl (default = 0) raises a clamped to ground track by the specified amount. Useful if gps track occasionally disappears into the ground.
#' @param ground_shadow (default = FALSE) adds a ground shadow to a flight gps trace
#'
#' @return Adds GPS trace to the current rayshader scene
#'
#' @examples
#' flight <- read_igc("path/to/igc/file")
#' add_gps_to_rayshader(a_raster, flight$lat, flight$long, flight$altitude)
#' @export
add_gps_to_rayshader <- function(raster_input, lat, long, alt, zscale, line_width = 1, colour = "red", alpha = 0.8, lightsaber = TRUE, clamp_to_ground = FALSE, raise_agl = 0, ground_shadow = FALSE){

  e <- raster::extent(raster_input)

  cell_size_x <- raster::pointDistance(c(e@xmin, e@ymin), c(e@xmax, e@ymin), lonlat = TRUE) / ncol(raster_input)

  cell_size_y <- raster::pointDistance(c(e@xmin, e@ymin), c(e@xmin, e@ymax), lonlat = TRUE) / nrow(raster_input)

  distances_x <- raster::pointDistance(c(e@xmin, e@ymin), cbind(flight$long, rep(e@ymin, nrow(flight))), lonlat = TRUE) / cell_size_x

  distances_y <- raster::pointDistance(c(e@xmin, e@ymin), cbind(rep(e@xmin, nrow(flight)), flight$lat), lonlat = TRUE) / cell_size_y

  if(clamp_to_ground | ground_shadow){

    sp_gps <-
      sp::SpatialPoints(cbind(long, lat),
                        proj4string = sp::CRS(
                          "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
                        )
      )

    gps_ground_line <- raster::extract(raster_input, sp_gps)

  }

  if(clamp_to_ground){
    track_altitude <- gps_ground_line
  } else {
    track_altitude <- alt
  }



  if(!lightsaber){
    rgl::lines3d(
      distances_x,  #lat
      track_altitude / zscale,  #alt
      -distances_y,  #long
      color = colour,
      alpha = alpha,
      lwd = line_width
    )
  } else {

    #render track 3 times with transparent & thicker outside

    rgl::lines3d(
      distances_x,
      track_altitude / zscale,
      -distances_y,
      color = colour,
      alpha = 0.2,
      lwd = line_width * 8,
      shininess = 25,
      fog = TRUE
    )

    rgl::lines3d(
      distances_x,
      track_altitude / zscale,
      -distances_y,
      color = colour,
      alpha = 0.6,
      lwd = line_width * 4,
      shininess = 80,
      fog = TRUE
    )

    rgl::lines3d(
      distances_x,
      track_altitude / zscale,
      -distances_y,
      color = lighten(colour),
      alpha = 1,
      lwd = 1,
      shininess = 120
    )

  }

  if(ground_shadow){
    rgl::lines3d(
      distances_x,
      gps_ground_line / zscale + raise_agl,
      -distances_y,
      color = "black",
      alpha = 0.4,
      lwd = line_width * 2,
      shininess = 25,
      fog = TRUE
    )
  }

}
