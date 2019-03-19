#' Adds a layer created using slippy_overlay() or slippy_raster() to a ggplot2 chart
#'
#' @param slippy_raster A raster raster returned by either \code{slippy_raster()} or \code{slippy_overlay(return_png = FALSE)}
#' @param alpha Opacity of the raster in ggplot
#'
#' @return a ggplot object
#'
#' @examples
#' \donttest{
#'
#' library(ggplot2)
#' library(geoviz)
#'
#' dem <- example_dem
#'
#' gg_overlay_image <-
#'   slippy_overlay(
#'     dem,
#'     image_source = "stamen",
#'     image_type = "watercolor",
#'     return_png = FALSE
#'   )
#'
#'  ggplot2::ggplot() +
#'    ggslippy(gg_overlay_image)
#'
#' }
#' @export
ggslippy <- function(slippy_raster, alpha = 1){

  image_df <- raster::as.data.frame(slippy_raster, xy = TRUE)

  names(image_df) <- c("x", "y", "red", "green", "blue")

  image_df$hex <- grDevices::rgb(image_df$red, image_df$green, image_df$blue, maxColorValue = 255)

  list(
    ggplot2::geom_raster(data = image_df, ggplot2::aes_string(x = "x", y = "y", fill = "hex"), alpha = alpha),
    ggplot2::coord_equal(),
    ggplot2::scale_fill_identity()
  )
}
