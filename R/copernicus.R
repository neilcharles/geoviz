copernicus <- function(){
  
  raster_mosaic <- raster::raster("copernicus/eu_dem_v11_E30N30.TIF")
  
  raster_mosaic = raster::projectRaster(raster_mosaic, crs = "+proj=longlat +datum=WGS84 +no_defs")
  
  raster::writeRaster(raster_mosaic, "copernicus/copernicus.raster", overwrite = TRUE)
  
}