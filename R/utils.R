square_bounding_box <- function(lat, long, square_km){
  #create point
  bounding_box <- sp::SpatialPoints(cbind(long, lat, square_km), proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  #Round target lat long to use to use as centre for equal area projection
  lat_round <- round(lat, 0)
  long_round <- round(long, 0)

  #Transform to be able to buffer
  bounding_box <-
    sp::spTransform(bounding_box, sp::CRS(paste0("+proj=laea +lat_0=", lat_round,
                                                 " +lon_0=", long_round,
                                                 " +x_0=4321000 +y_0=3210000 +ellps=GRS80 ",
                                                 "+towgs84=0,0,0,0,0,0,0 +units=m +no_defs")))

  #create buffer square
  bounding_shape <- rgeos::gBuffer(bounding_box, width = bounding_box$square_km * 1000, quadsegs=1, capStyle="SQUARE")

  #reproject (skipping to try to work with laea)
  #bounding_shape <- sp::spTransform(bounding_shape, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

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

raster_to_png <- function(tile_raster, file_path)
{
  if (!inherits(tile_raster, "RasterBrick")) {
    stop("tile raster must be a RasterBrick. This is output from tg_composite().")
  }
  tile_raster@data@values <- sweep(tile_raster@data@values,
                                   MARGIN = 2, STATS = tile_raster@data@max, FUN = "/")
  png::writePNG(raster::as.array(tile_raster), target = file_path)
}
