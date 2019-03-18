#' Creates an overlay image from various sources using Miles McBain's slippymath
#'
#' @param slippy_raster A raster raster returned by either \code{slippy_raster()} or \code{slippy_overlay(return_png = FALSE)}
#'
#' @return a ggplot object
#'
#' @examples
#' \donttest{
#' example...
#' }
#' @export
ggslippy <- function(slippy_raster){

  image_df <- raster::as.data.frame(slippy_raster, xy = TRUE)

  names(image_df) <- c("x", "y", "red", "green", "blue")

  image_df$hex <- grDevices::rgb(image_df$red, image_df$green, image_df$blue, maxColorValue = 255)

  list(
    ggplot2::geom_raster(data = image_df, ggplot2::aes_string(x = "x", y = "y", fill = "hex"), alpha = 1),
    ggplot2::coord_equal(),
    ggplot2::scale_fill_identity()
  )
}
