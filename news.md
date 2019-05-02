## 0.2.1

New features:
- New function mapzen_dem() provides higher resolution DEM's than mapbox_dem(), without requiring an api key. Mapzen data has variable maximum resolutions in different parts of the world, see [Mapzen data sources](https://github.com/tilezen/joerd/blob/master/docs/data-sources.md).
- mapbox_dem() and mapzen_dem() will now accept a vector of lat-long points and create a rectangular raster to contain them, to make it easy to visualise GPS tracks
- Mapbox custom styles can be downloaded using get_slippy_map(image_source = "mapbox", image_type = "username/mapid"). This also works for slippy_overlay()
- New vignette illustrating how to use mapzen_dem() to draw Hawaii

Bug fixes:
- Projections changed to laea centred on the requested lat-long to ensure square areas are actually square and not distorted by map projection.
- elevation_transparency() and elevation_shade() will now accept a raster_dem that contains NA values and raise a warning rather than an error
- 'EPSG' changed to 'epsg' in add_gps_to_rayshader()
- Changed readr::read_csv for readr::read_lines in read_igc() to remove parsing warnings
- Check in slippy_overlay() whether map image already has an alpha layer before adding one (fixes stamen toner)
- Removed stamen terrain in documentation, because terrain returns a DEM, not an image. Could create stamen_dem(), but seems unnecessary, when mapzen_dem() and mapbox_dem() already exist

Changes:
- mapbox_dem() and mapzen_dem() return a raster with the number of cells defined by 'max_tiles', rather than superimposing a resolution over the top, that had previously defaulted to 1000x1000. This allows you to more easily draw high resolution Rayshader scenes and doesn't arbitrarily drop the resolution of your scene if you forgot to increase resolution from the default.
- resolution option in slippy_raster() is deprecated
- Dropped max_tiles defaults from 30 to 10 as a better compromise between speed and rayshader scene resolution.


## 0.2.0

Initial CRAN submission
