#' Load an IGC file
#'
#' @param path target IGC file
#'
#' @return processed IGC file
#'
#' @examples
#' \donttest{
#' read_igc("file.igc")
#' }
#' @export
read_igc <- function(path){

  igc.data <- readr::read_csv(path)

  names(igc.data)[1] <- "X1"

  flight.points <- igc.data %>%
    dplyr::select("X1") %>% #Keeps first column only in case of stray commas creating additional fields
    dplyr::filter(substr(.data$X1, 1, 1) == "B") %>%
    #Separate points data
    tidyr::separate(
      .data$X1,
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
        substr(.data$time_igc, 1, 2),
        ":",
        substr(.data$time_igc, 3, 4),
        ":",
        substr(.data$time_igc, 5, 6)
      ),
      lat_dms = paste0(
        substr(.data$lat_igc, 1, 2),
        "d",
        substr(.data$lat_igc, 3, 4),
        ".",
        substr(.data$lat_igc, 5, 7),
        "'",
        substr(.data$lat_igc, 8, 8)
      ),
      long_dms = paste0(
        substr(.data$long_igc, 1, 3),
        "d",
        substr(.data$long_igc, 4, 5),
        ".",
        substr(.data$long_igc, 6, 8),
        "'",
        substr(.data$long_igc, 9, 9)
      ),
      altitude_pressure = as.numeric(gsub("A", "", .data$altitude_igc_pressure)),
      altitude = as.numeric(.data$altitude_igc_gps)
    ) %>%
    #Convert to decimal lat long
    dplyr::mutate(
      time_hms = chron::chron(times = .data$time_char),
      lat = methods::as(sp::char2dms(.data$lat_dms), "numeric"),
      long = methods::as(sp::char2dms(.data$long_dms), "numeric")
    ) %>%
    dplyr::arrange(.data$time_hms) %>%
    dplyr::filter(!(.data$lat==0 & .data$long==0 & .data$altitude==0))  #dump bad rows where all data is 0

  return(flight.points)
}
