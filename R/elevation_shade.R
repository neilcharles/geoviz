#' Produces an elevation shaded png from a raster
#'
#' @param raster_input a raster
#' @param elevation_palette a vector of colours to use for elevation shading
#' @param return_png \code{TRUE} to return a png image. \code{FALSE} will return a raster
#'
#' @return elevation shaded png image
#'
#' @examples
#' elevation_shade(example_raster)
#' @export
elevation_shade <- function(raster_input, elevation_palette = c("#54843f", "#808080", "#FFFFFF"), return_png = TRUE){
  raster_values <- raster::values(raster_input)

  colours <- grDevices::colorRamp(elevation_palette)(rescale(raster_values, 0,1,min(raster_values), max(raster_values)))

  red <- raster_input
  raster::values(red) <- colours[,1]
  green <- raster_input
  raster::values(green) <- colours[,2]
  blue <- raster_input
  raster::values(blue) <- colours[,3]

  image_raster <- raster::brick(list(red, green, blue))

  if(!return_png){
    return(image_raster)
  }

  temp_image <- tempfile(fileext = ".png")

  slippymath::raster_to_png(image_raster, temp_image)

  terrain_image <- png::readPNG(temp_image)

  file.remove(temp_image)

  #add an alpha layer for ease of overlaying in rayshader
  alpha_layer <- matrix(1, nrow = dim(terrain_image)[1], ncol = dim(terrain_image)[2])

  terrain_image <- abind::abind(terrain_image, alpha_layer)

  terrain_image
}
