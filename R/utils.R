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

track_bounding_box <- function(lat_points, long_points, width_buffer){

  #Error: package rgdal is required for spTransform methods
  #rgdal added to Imports and called here to pass checks
  temp_rgdal <- rgdal::getGDALCheckVersion()

  #Make a bounding box around the track points
  bounding_box <- sp::SpatialPoints(cbind(long_points, lat_points),
                                    proj4string = sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  bounding_box <- methods::as(raster::extent(bounding_box), 'SpatialPolygons')

  sp::proj4string(bounding_box) <- "+proj=longlat +datum=WGS84 +no_defs"

  #Reproject for rgeos
  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))

  #Pad a border around the bounding box
  bounding_shape <- rgeos::gBuffer(bounding_box, capStyle = "SQUARE", width = width_buffer * 1000)

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


compose_tile_grid <- function (tile_grid, images)
{
  #Adapted from slippymath to cope with 8 bit png images (1 layer). Slippymath saves them as .jpg but they aren't
  bricks <- purrr::pmap(.l = list(x = tile_grid$tiles$x, y = tile_grid$tiles$y,
                                  image = images), .f = function(x, y, image, zoom) {
                                    bbox <- slippymath::tile_bbox(x, y, zoom)

                                    raster_img <- raster::brick(image, crs = attr(bbox,
                                                                                  "crs")$proj4string)
                                    #adaptation --------------------
                                    if (dim(raster_img)[3]==1){ #tile_raster has one layer
                                      raster_img <- raster::raster(image, crs = attr(bbox,
                                                                                     "crs")$proj4string)

                                      #Apply the raster's colortable to create a 3 layer rgb version
                                      raster_img <- raster::setValues(raster::brick(raster_img, raster_img, raster_img),
                                                          t(col2rgb(raster_img@legend@colortable))[raster::values(raster_img) + 1,])
                                    }
                                    #-------------------------------

                                    raster::extent(raster_img) <- raster::extent(bbox[c("xmin",
                                                                                        "xmax", "ymin", "ymax")])
                                    raster_img
                                  }, zoom = tile_grid$zoom)
  geo_refd_raster <- do.call(raster::merge, bricks)
  geo_refd_raster
}


raster_to_png <- function(tile_raster, file_path)
{

  #Adapted from slippymath to fix margin problem
  tile_raster@data@values <- sweep(tile_raster@data@values,
                                   MARGIN = 2, STATS = tile_raster@data@max, FUN = "/")

  png::writePNG(raster::as.array(tile_raster), target = file_path)

}
