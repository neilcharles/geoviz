#' Load an IGC file
#'
#' @param path target IGC file
#'
#' @return processed IGC file
#'
#' @examples
#' read_igc("file.igc")
#' @importFrom magrittr %>%
#' @export
read_igc <- function(path){

  igc.data <- readr::read_csv(path)

  names(igc.data)[1] <- "X1"

  flight.points <- igc.data %>%
    dplyr::select(X1) %>% #Keeps first column only in case of stray commas creating additional fields
    dplyr::filter(substr(X1, 1, 1) == "B") %>%
    #Separate points data
    tidyr::separate(
      X1,
      sep = c(1, 7, 15, 24, 30, 35),
      into = c(
        "id",
        "time_igc",
        "lat_igc",
        "long_igc",
        "altitude_igc_pressure",
        "altitude_igc_gps",
        "discarded"
      )
    ) %>%
    #Format degrees minutes seconds
    dplyr::mutate(
      time_char = paste0(
        substr(time_igc, 1, 2),
        ":",
        substr(time_igc, 3, 4),
        ":",
        substr(time_igc, 5, 6)
      ),
      lat_dms = paste0(
        substr(lat_igc, 1, 2),
        "d",
        substr(lat_igc, 3, 4),
        ".",
        substr(lat_igc, 5, 7),
        "'",
        substr(lat_igc, 8, 8)
      ),
      long_dms = paste0(
        substr(long_igc, 1, 3),
        "d",
        substr(long_igc, 4, 5),
        ".",
        substr(long_igc, 6, 8),
        "'",
        substr(long_igc, 9, 9)
      ),
      altitude_pressure = as.numeric(gsub("A", "", altitude_igc_pressure)),
      altitude = as.numeric(altitude_igc_gps)
    ) %>%
    #Convert to decimal lat long
    dplyr::mutate(
      time_hms = chron::chron(times = time_char),
      lat = as(sp::char2dms(lat_dms), "numeric"),
      long = as(sp::char2dms(long_dms), "numeric")
    ) %>%
    dplyr::arrange(time_hms) %>%
    dplyr::filter(!(lat==0 & long==0 & altitude==0))  #dump bad rows where all data is 0

  return(flight.points)
}
