#' Adds a layer created using slippy_overlay() or slippy_raster() to a 'ggplot2' chart
#'
#' @param slippy_raster A raster raster returned by either \code{slippy_raster()} or \code{slippy_overlay(return_png = FALSE)}
#' @param alpha Opacity of the raster in 'ggplot2'
#' @param set_coord_equal \code{TRUE} returns a square plot
#'
#' @return a ggplot object
#'
#' @examples
#' library(ggplot2)
#' library(geoviz)
#'
#' dem <- example_raster()
#'
#' dem <- raster::aggregate(dem, 10) #aggregate to speed up ggplot for testing
#'
#' gg_overlay_image <- slippy_overlay(
#'   dem,
#'   image_source = "stamen",
#'   image_type = "watercolor",
#'   return_png = FALSE,
#'   max_tiles = 2
#'   )
#'
#' ggplot() +
#'   ggslippy(gg_overlay_image, set_coord_equal = FALSE)
#' @export
ggslippy <- function(slippy_raster, alpha = 1, set_coord_equal = TRUE){

  image_df <- raster::as.data.frame(slippy_raster, xy = TRUE)

  names(image_df) <- c("x", "y", "red", "green", "blue")

  image_df$hex <- grDevices::rgb(image_df$red, image_df$green, image_df$blue, maxColorValue = 255)

  gg_out <- list(
    ggplot2::geom_raster(data = image_df, ggplot2::aes_string(x = "x", y = "y", fill = "hex"), alpha = alpha),
    ggplot2::scale_fill_identity()
  )

  if(set_coord_equal){
    gg_out <- append(gg_out, ggplot2::coord_equal())
  }

  gg_out
}
