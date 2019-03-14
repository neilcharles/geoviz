rescale <- function (x, nx1, nx2, minx, maxx){
  nx = nx1 + (nx2 - nx1) * (x - minx)/(maxx - minx)
  return(nx)
}
