#' Simulates a dry brushing effect. Differs from Altitude transparency in that colour is applied based on local altitude peaks, not across the whole raster
#'
#' @param altitude_raster A raster
#' @param aggregation_factor grid size to determine local altitude peaks
#' @param max_colour_altitude Altitude below which colours will be graduated across elevation_palette
#' @param opacity overall opacity of the returned image
#' @param elevation_palette Colour scheme c(colour for low altitude, colour for high altitude)
#'
#' @return An image with a drybrished colour effect, highlighting local peaks
#'
#' @examples
#' overlay_image <- drybrush(example_raster)
#' @export
drybrush <- function(altitude_raster, aggregation_factor = 10, max_colour_altitude = 30, opacity = 0.5, elevation_palette = c("#3f3f3f", "#ffa500")){

  raster_base <- raster::aggregate(altitude_raster, fun = min, fact = 10)

  raster_base <- raster::resample(raster_base, altitude_raster)

  drybrush_distance <- altitude_raster - raster_base

  drybrush_distance[is.na(drybrush_distance)] <- 0
  drybrush_distance[drybrush_distance < 0] <- 0

  drybrush_distance_std <- drybrush_distance / max_colour_altitude

  drybrush_distance_std[drybrush_distance_std > 1] <- 1

  elevation_overlay <- elevation_shade(drybrush_distance_std, elevation_palette = elevation_palette)

  elevation_overlay[,,4] <-  opacity

  elevation_overlay

}
