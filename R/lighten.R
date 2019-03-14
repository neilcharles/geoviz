lighten <- function(color, factor=0.2){
  col <- grDevices::col2rgb(color)
  col <- col+ (255 - col) * factor
  col <- grDevices::rgb(t(col), maxColorValue=255)
  col
}
