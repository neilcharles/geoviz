square_bounding_box <- function(lat, long, square_km){
  #create point
  bounding_box <- sp::SpatialPoints(cbind(long, lat, square_km), proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  #Transform to be able to buffer
  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

  #create buffer square
  bounding_shape <- rgeos::gBuffer(bounding_box, width = bounding_box$square_km * 1000, quadsegs=1, capStyle="SQUARE")

  #reproject
  bounding_shape <- sp::spTransform(bounding_shape, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  return(bounding_shape)
}

rescale <- function (x, nx1, nx2, minx, maxx){
  nx = nx1 + (nx2 - nx1) * (x - minx)/(maxx - minx)
  return(nx)
}

lighten <- function(color, factor=0.2){
  col <- grDevices::col2rgb(color)
  col <- col+ (255 - col) * factor
  col <- grDevices::rgb(t(col), maxColorValue=255)
  col
}
