#' Creates an overlay image from various sources using Miles McBain's slippymath
#'
#' @param raster_input A raster with WGS84 coordinates
#' @param image_source Source for the overlay image. Valid entries are "mapbox", "stamen".
#' @param image_type The type of overlay to request. "satellite" (mapbox) or "watercolor", "toner", "terrain" (stamen)
#' @param api_key API key (required for mapbox)
#'
#' @return an overlay image for raster_input
#'
#' @examples
#' \donttest{
#' overlay_image <- slippy_overlay(example_raster, image_source = "stamen", image_type = "watercolor")
#' }
#' @export
slippy_overlay <- function(raster_input, image_source = "mapbox", image_type, api_key){

  bounding_box <- methods::as(raster::extent(raster_input), "SpatialPolygons")

  sp::proj4string(bounding_box) <- as.character(raster::crs(raster_input))

  bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))

  xt_scene <- raster::extent(bounding_box)

  overlay_bbox <-
    sf::st_bbox(c(xmin = xt_scene@xmin,
                  xmax = xt_scene@xmax,
                  ymin = xt_scene@ymin,
                  ymax = xt_scene@ymax),
                crs = sf::st_crs("+proj=longlat +datum=WGS84 +no_defs"))

  tile_grid <- slippymath::bbox_to_tile_grid(overlay_bbox, max_tiles = 30)

  if(image_source=="stamen"){

    query_string <- "http://tile.stamen.com/watercolor/{zoom}/{x}/{y}.jpg"

  } else if (image_source=="mapbox"){

    query_string <- paste0("https://api.mapbox.com/v4/mapbox.satellite/{zoom}/{x}/{y}.jpg90",
                           "?access_token=",
                           api_key)
  } else {
    stop(glue::glue("unknown source '{image_source}'"))
  }

  #create a temporary dir to hold tiles
  tile_dir <- tempfile(pattern = "map_tiles_")
  dir.create(tile_dir)

  images <-
    purrr::pmap(tile_grid$tiles,
                function(x, y, zoom){
                  outfile <- glue::glue("{tile_dir}/{x}_{y}.jpg")
                  curl::curl_download(url = glue::glue(query_string),
                                      destfile = outfile)
                  outfile
                },
                zoom = tile_grid$zoom)

  raster_out <- slippymath::compose_tile_grid(tile_grid, images)

  unlink(tile_dir, recursive = TRUE)  #kill the temp directory containing tiles

  raster_out = raster::projectRaster(raster_out, crs = raster::crs(raster_input))

  raster_out <- raster::resample(raster_out, raster_input)

  temp_map_image <- tempfile(fileext = ".png")

  slippymath::raster_to_png(raster_out, temp_map_image)

  map_image <- png::readPNG(temp_map_image)
  file.remove(temp_map_image)

  alpha_layer <- matrix(1, nrow = dim(map_image)[1], ncol = dim(map_image)[2])

  map_image <- abind::abind(map_image, alpha_layer)

  return(map_image)
}
