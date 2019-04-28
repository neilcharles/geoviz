#' Obtains and merges map tiles from various sources using the 'slippymath' package
#'
#' @param bounding_box Any object for which raster::extent() can be calculated. Your object must use WGS84 coordinates.
#' @param image_source Source for the overlay image. Valid entries are "mapbox", "mapzen", "stamen".
#' @param image_type The type of overlay to request. "satellite", "mapbox-streets-v8", "mapbox-terrain-v2", "mapbox-traffic-v1", "terrain-rgb", "mapbox-incidents-v1" (mapbox), "dem" (mapzen) or "watercolor", "toner", "toner-background", "toner-lite" (stamen). You can also request a custom Mapbox style by specifying \code{image_source = "mapbox", image_type = "username/mapid"}
#' @param max_tiles Maximum number of tiles to be requested by 'slippymath'
#' @param api_key API key (required for 'mapbox')
#'
#' @return a rasterBrick with the same dimensions (but not the same resolution) as bounding_box
#'
#' @examples
#' map <- get_slippy_map(example_raster(),
#'   image_source = "stamen",
#'   image_type = "watercolor",
#'   max_tiles = 5)
#' @export
get_slippy_map <- function(bounding_box, image_source = "stamen", image_type = "watercolor", max_tiles = 10, api_key){

  #Transform bounding_box to WGS84
  if(stringr::str_detect(class(bounding_box)[1], "Raster")){
    bounding_box <- raster::projectRaster(bounding_box, crs = "+proj=longlat +datum=WGS84 +no_defs")
  } else {
    bounding_box <- sp::spTransform(bounding_box, sp::CRS("+proj=longlat +datum=WGS84 +no_defs"))
  }

  xt_scene <- raster::extent(bounding_box)

  overlay_bbox <-
    sf::st_bbox(c(xmin = xt_scene@xmin,
                  xmax = xt_scene@xmax,
                  ymin = xt_scene@ymin,
                  ymax = xt_scene@ymax),
                crs = sf::st_crs("+proj=longlat +datum=WGS84 +no_defs"))

  tile_grid <- slippymath::bbox_to_tile_grid(overlay_bbox, max_tiles = max_tiles)

  if(tile_grid$zoom > 11 & image_source == "mapbox" & image_type == "terrain-rgb"){
    message(glue::glue("Zoom level with max_tiles = {max_tiles} is {tile_grid$zoom}. Resetting zoom to 11, which is max for mapbox.terrain-rgb."))
    tile_grid <- slippymath::bbox_to_tile_grid(overlay_bbox, zoom = 11)
  }


  #Stamen Maps
  if(image_source=="stamen"){
    if(stringr::str_detect(image_type, "watercolor")){
      query_string <- paste0("http://tile.stamen.com/", image_type, "/{zoom}/{x}/{y}.jpg")
    } else {
      query_string <- paste0("http://tile.stamen.com/", image_type, "/{zoom}/{x}/{y}.png")
    }

  #Mapbox maps
  } else if (image_source=="mapbox"){

    if(stringr::str_detect(image_type, "\\/")){ #image_type is a custom mapbox map url

      query_string <- paste0("https://api.mapbox.com/styles/v1/", image_type, "/tiles/{zoom}/{x}/{y}",
                             "?access_token=",
                             api_key)

    } else {

    query_string <- paste0("https://api.mapbox.com/v4/mapbox.", image_type, "/{zoom}/{x}/{y}.jpg90",
                           "?access_token=",
                           api_key)
    }

  #Mapzen maps
  } else if (image_source=="mapzen" & image_type=="dem"){

    query_string <- "https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{zoom}/{x}/{y}.png"

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

  raster_out <- compose_tile_grid(tile_grid, images) #not slippymath version due to png issue

  #Transform raster to match projection of the original bounding box
  raster_out <- raster::projectRaster(raster_out, crs = raster::crs(bounding_box))

  unlink(tile_dir, recursive = TRUE)  #kill the temp directory containing tiles

  return(raster_out)
}
