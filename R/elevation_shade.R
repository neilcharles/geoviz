#' Produces an elevation shaded png from a raster
#'
#' @param raster_input a raster
#' @param elevation_palette a vector of colours to use for elevation shading
#'
#' @return elevation shaded png image
#'
#' @examples
#' elevation_shade(a_raster)
#' @export
elevation_shade <- function(raster_input, elevation_palette = c("#54843f", "#808080", "#FFFFFF")){
  col_ramp <- grDevices::colorRampPalette(elevation_palette)

  #Create and save image to disk
  grDevices::png("elevation_shading.png", width=ncol(raster_input), height=nrow(raster_input), units = "px", pointsize = 1)

  graphics::par(mar = c(0,0,0,0), xaxs = "i", yaxs = "i") #create a borderless image

  raster::image(
    raster_input,
    col = col_ramp(64),
    maxpixels = raster::ncell(raster_input),
    axes = FALSE
  )

  grDevices::dev.off()

  #Load generated png image
  terrain_image <- png::readPNG("elevation_shading.png")

  file.remove("elevation_shading.png")

  #add an alpha layer for ease of overlaying in rayshader
  alpha_layer <- matrix(1, nrow = dim(terrain_image)[1], ncol = dim(terrain_image)[2])

  terrain_image <- abind::abind(terrain_image, alpha_layer)

  terrain_image
}
