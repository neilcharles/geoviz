## 0.2.1

- New function mapzen_dem() provides higher resolutions than mapbox_dem() without an api key
- Projections changed to laea centred on the requested lat-long to ensure square areas are actually square and not distorted by projection.
- mapbox_dem() and mapzen_dem() will return a raster withe number of cells defined by the zoom level of the requested map tiles, rather superimposing a resolution over the top (that had previously defaulted to 1000x1000). This allows you to more easily draw high resolution Rayshader scenes and doesn't arbitrarily drop the resolution of your scene if you forgot to increase resolution from the default.


## 0.2.0

Initial CRAN submission
