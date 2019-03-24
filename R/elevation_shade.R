#' Produces an elevation shaded png from a raster
#'
#' @param raster_dem a raster
#' @param elevation_palette a vector of colours to use for elevation shading
#' @param return_png \code{TRUE} to return a png image. \code{FALSE} will return a raster
#' @param png_opacity Opacity of the returned image if requesting a png
#'
#' @return elevation shaded png image
#'
#' @examples
#' elevation_shade(example_raster())
#' @export
elevation_shade <- function(raster_dem, elevation_palette = c("#54843f", "#808080", "#FFFFFF"), return_png = TRUE, png_opacity = 1){

  rasterValues <- raster::values(raster_dem)

  colours <- grDevices::colorRamp(elevation_palette)(rescale(rasterValues, 0,1,min(rasterValues), max(rasterValues)))

  red <- raster_dem
  raster::values(red) <- colours[,1]
  green <- raster_dem
  raster::values(green) <- colours[,2]
  blue <- raster_dem
  raster::values(blue) <- colours[,3]

  rasterImage <- raster::brick(list(red, green, blue))

  if(!return_png){
    return(rasterImage)
  }

  tempImage <- tempfile(fileext = ".png")

  slippymath::raster_to_png(rasterImage, tempImage)

  terrain_image <- png::readPNG(tempImage)

  file.remove(tempImage)

  #add an alpha layer for ease of overlaying in rayshader
  alpha_layer <- matrix(png_opacity, nrow = dim(terrain_image)[1], ncol = dim(terrain_image)[2])

  terrain_image <- abind::abind(terrain_image, alpha_layer)

  terrain_image
}
