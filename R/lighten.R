lighten <- function(color, factor=0.2){
  col <- col2rgb(color)
  col <- col+ (255 - col) * factor
  col <- rgb(t(col), maxColorValue=255)
  col
}
