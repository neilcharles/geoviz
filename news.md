## 0.2.1

New features:
- New function mapzen_dem() provides higher resolution DEM's than mapbox_dem(), without requiring an api key. Mapzen data has variable maximum resolutions in different parts of the world, see [Mapzen data sources](https://github.com/tilezen/joerd/blob/master/docs/data-sources.md).

Bug fixes:
- Projections changed to laea centred on the requested lat-long to ensure square areas are actually square and not distorted by map projection.
- elevation_transparency() and elevation_shade() will now accept a raster_dem that contains NA values and raise a warning rather than an error

Changes:
- mapbox_dem() and mapzen_dem() return a raster with the number of cells defined by 'max_tiles', rather than superimposing a resolution over the top, that had previously defaulted to 1000x1000. This allows you to more easily draw high resolution Rayshader scenes and doesn't arbitrarily drop the resolution of your scene if you forgot to increase resolution from the default.
- resolution option in slippy_raster() is deprecated
- Dropped max_tiles defaults from 30 to 20 as a better compromise between speed and rayshader scene resolution.


## 0.2.0

Initial CRAN submission
