#' Track points from a paragliding flight IGC file
#'
#' An example IGC file imported with read_igc()
#'
#' @format A tibble with 2773 rows and 15 variables:
#' \describe{
#'   \item{id}{Original IGC ID field}
#'   \item{time_igc}{timestamp in original igc format}
#'   \item{lat_igc}{latitude in original igc format}
#'   \item{long_igc}{lnogitude in original igc format}
#'   \item{altitude_igc_pressure}{pressure altitude in original igc format}
#'   \item{altitude_igc_gps}{gps altitude in original igc format}
#'   \item{discarded}{discarded field in original igc format}
#'   \item{time_char}{character formatted time as hh:mm:ss}
#'   \item{lat_dms}{latitude in degrees, minutes, seconds}
#'   \item{long_dms}{longitude in degrees, minutes, seconds}
#'   \item{altitude_pressure}{numeric pressure altitude in feet}
#'   \item{altitude}{numeric gps altitude in feet}
#'   \item{time_hms}{time}
#'   \item{lat}{wgs84 latitude}
#'   \item{long}{wgs84 longitude}
#'
#' }
#' @source \url{xcleague.com}
"example_igc"
#' A small elevation raster
#'
#' 25m resolution Digital Elevation Map of part of the UK Lake District
#'
#' @format A RasterLayer 645x645
#' \describe{
#'   \item{values}{terrain elevation in metres}
#'
#' }
#' @source \url{https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1?tab=mapview}
"example_raster"
