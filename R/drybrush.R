#' Simulates a dry brushing effect. Differs from elevation_transparency() in that colour is applied based on local altitude peaks, not across the whole raster
#'
#' @param raster_dem A raster
#' @param aggregation_factor grid size to determine local altitude peaks
#' @param max_colour_altitude Altitude below which colours will be graduated across elevation_palette
#' @param opacity overall opacity of the returned image
#' @param elevation_palette Colour scheme c(colour_for_low_altitude, colour_for_high_altitude)
#'
#' @return An image with a drybrushed colour effect, highlighting local peaks
#'
#' @examples
#' overlay_image <- drybrush(example_raster())
#' @export
drybrush <- function(raster_dem, aggregation_factor = 10, max_colour_altitude = 30, opacity = 0.5, elevation_palette = c("#3f3f3f", "#ffa500")){

  rasterBase <- raster::aggregate(raster_dem, fun = min, fact = 10)

  rasterBase <- raster::resample(rasterBase, raster_dem)

  drybrush_distance <- raster_dem - rasterBase

  drybrush_distance[is.na(drybrush_distance)] <- 0
  drybrush_distance[drybrush_distance < 0] <- 0

  drybrush_distance_std <- drybrush_distance / max_colour_altitude

  drybrush_distance_std[drybrush_distance_std > 1] <- 1

  elevation_overlay <- elevation_shade(drybrush_distance_std, elevation_palette = elevation_palette)

  elevation_overlay[,,4] <-  opacity

  elevation_overlay

}
