# Geoviz

Helper functions to draw [rayshader](https://github.com/tylermorganwall/rayshader) scenes with elevation shading and GPS tracks (and anything else I fancy adding)

### Installing

```R
devtools::install_github("neilcharles/geoviz")
```

### Example

To draw scenes of UK geography using OS Terrain 50 data.

Download [OS Terrain 50](https://www.ordnancesurvey.co.uk/business-and-government/products/terrain-50.html).

Unpack all of the *GRID*.zip files into a single directory

```R
library(geoviz)
library(ggmap)

# Stitch all of the GRID files together into a single raster of the entire UK.
# This will quite take some time! But it only needs to be done once and will save the raster it creates.
mosaic_uk_grid("path/to/grid/zips/")

# Load the merged raster file
raster_mosaic <- raster::raster("mosaic_uk_grid.grd")

# Read an IGC file. If you just want an example GPS file, you can download one here
# http://www.xcleague.com/xc/flights/2013554.html
# Click the 'tracklog' button in the bottom left
# Alternatively use any source of decimal lat-long and altitude data that you like in the script below
flight <- read_igc("CharlesN-2013-04-19.igc")

#Get lat long coordinates for a UK location. This is a spot in the middle of the Lake district.
coords <- ggmap::geocode("wythburn, UK")

square_km <- 10  #length of one side of the square to be cropped from the whole UK raster

raster_crop <- crop_raster_square(raster_mosaic, coords$lat, coords$lon, square_km)

r <- render_location(raster_crop)

rayshader::plot_3d(
  r$r,
  r$elmat,
  zscale = 50,
  shadow = TRUE
)

add_gps_to_rayshader(raster_crop, flight$lat, flight$long, flight$altitude, 50)
```
