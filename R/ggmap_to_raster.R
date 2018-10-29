ggmap_to_raster = function(gmap){

  #https://rpubs.com/alobo/getmapCRS

  mgmap <- as.matrix(gmap)

  vgmap <- as.vector(mgmap)

  vgmaprgb <- col2rgb(vgmap)

  gmapr <- matrix(vgmaprgb[1, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
  gmapg <- matrix(vgmaprgb[2, ], ncol = ncol(mgmap), nrow = nrow(mgmap))
  gmapb <- matrix(vgmaprgb[3, ], ncol = ncol(mgmap), nrow = nrow(mgmap))

  rgmaprgbGM <- raster::brick(raster::raster(gmapr), raster::raster(gmapg), raster::raster(gmapb))

  rm(gmapr, gmapg, gmapb)

  raster::projection(rgmaprgbGM) <- sp::CRS("+init=epsg:3857")

  unlist(attr(gmap, which = "bb"))[c(2, 4, 1, 3)]

  rprobextSpDF <- as(raster::extent(unlist(attr(gmap, which = "bb"))[c(2, 4, 1, 3)]), "SpatialPolygons")

  raster::projection(rprobextSpDF) <- sp::CRS("+init=epsg:4326")

  rprobextGM <- sp::spTransform(rprobextSpDF, sp::CRS("+init=epsg:3857"))

  raster::extent(rgmaprgbGM) <- c(rprobextGM@bbox[1, ], rprobextGM@bbox[2, ])

  return(rgmaprgbGM)

}
