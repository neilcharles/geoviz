#' Colours and hill shades a raster using rayshader
#' crop large rasters first using crop_raster_square()
#' Use rayshader::plot_3d() to visualise the result
#'
#' @param raster_input a raster
#' @param sphere_palette A rayshader palette to use for sphere_shade(), e.g. "bw" or "desert".
#' @param elevation_palette a vector of colours to use for elevation shading
#' @param sunangle rayshader sun angle
#' This palette will be multiplied by your elevation palette so use "bw" to maintain original hues.
#'
#' @return rendedered scene to visualise with rayshader::plot_3d()
#' returns a list. r$r is the rendered scene and r$elmat is the elevation matrix
#'
#' @examples
#' render_location(a_raster, 54.4282623, -2.9787427, square_km = 10)
#'
#' plot_3d(
#'   r$r,
#'   r$elmat,
#'   zscale = 50,
#'   shadow = TRUE
#' )
#' @export
render_location <- function(raster_input, sphere_palette = "bw", elevation_palette = c("#54843f", "#808080", "#FFFFFF"), sunangle = 270){

  #-------------- Create an elevation shaded png -----------------------------

  col_ramp <- colorRampPalette(elevation_palette)

  #Create and save image to disk
  png("elevation_shading.png", width=ncol(raster_input), height=nrow(raster_input), units = "px", pointsize = 1)

  par(mar = c(0,0,0,0), xaxs = "i", yaxs = "i") #create a borderless image

  raster::image(
    raster_input,
    col = col_ramp(64),
    maxpixels = raster::ncell(raster_input),
    axes = FALSE
  )

  dev.off()

  #Load generated png image
  terrain_image <- png::readPNG("elevation_shading.png")

  #----------------- Draw Scene -----------------------------------------------

  elmat = matrix(
    raster::extract(raster_input, raster::extent(raster_input), method = 'bilinear'),
    nrow = ncol(raster_input),
    ncol = nrow(raster_input)
  )


  ss <- elmat %>%
    rayshader::sphere_shade(sunangle = sunangle, texture = sphere_palette)


  shaded_elevation <- terrain_image * ss + (1 - ss) * 0.25


  r <- shaded_elevation %>%
    rayshader::add_water(rayshader::detect_water(elmat, min_area = 20, cutoff = 0.995), color="imhof4") %>%
    rayshader::add_shadow(rayshader::ray_shade(elmat, anglebreaks = seq(60, 90), sunangle = sunangle, multicore = TRUE, lambert = FALSE, remove_edges = FALSE)) %>%
    rayshader::add_shadow(rayshader::ambient_shade(elmat, multicore = TRUE, remove_edges = FALSE))

  return(list("elmat" = elmat, "r" = r))

}
