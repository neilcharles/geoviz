context("imagery")

library(geoviz)

igc <- example_igc
DEM <- example_raster

# Removed tests because ggmap produces warning "no non-missing arguments to min; returning Inf"
# test_that("ggmap_image returns data", {
#   expect_equal(length(ggmap_image(DEM, source = "stamen", maptype = "watercolor", zoom = 10)), 1664100)
# })

# test_that("elevation_shade returns data", {
#   expect_equal(length(elevation_shade(DEM, elevation_palette = c("#000000", "#FFFFFF"))), 1664100)
# })
