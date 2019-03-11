#' Stitches together .asc files into a single raster
#' Requires a target directory of .asc files or .zip files containing .asc files
#'
#' @param asc_path path to files that are to be stitched together
#' @param extract_zip \code{FALSE} to target .asc files, \code{TRUE} if your .asc files are zipped.
#' @param file_match regex pattern to match .asc files, either in asc_path or in zip files.
#' @param zip_file_match regex pattern to match .zip files
#' @param raster_output_file raster file to be created (will overwrite existing files)
#'
#' @return TRUE
#'
#' @examples
#' \donttest{
#' mosaic_asc("path/to/grid/zip_files/", "output/file.raster")
#' }
#' @export
mosaic_asc <-
  function(asc_path,
           extract_zip = FALSE,
           file_match = ".*.asc",
           zip_file_match = ".*.zip",
           raster_output_file = "mosaic_out.raster") {
    if (substr(asc_path, nchar(asc_path), nchar(asc_path)) != "/") {
      asc_path <- glue::glue("{asc_path}/")
    }

    read_from_zip <- function(zip_file, file_match, extract_path) {
      asc_files_in_zip <- utils::unzip(zip_file, list = TRUE) %>%
        dplyr::filter(stringr::str_detect(.data$Name, file_match)) %>%
        dplyr::pull(.data$Name)

      utils::unzip(zip_file, asc_files_in_zip, exdir = extract_path)
    }

    if (extract_zip) {
      message("Unzipping files...")

      #create a temporary dir to hold unzipped asc files
      unzip_dir <- tempfile(pattern = "asc_unzip_")
      dir.create(unzip_dir)

      zip_files <-
        tibble::tibble(zip_files = list.files(asc_path, zip_file_match, full.names = TRUE)) %>%
        dplyr::pull("zip_files") %>%
        purrr::walk(.f = ~  read_from_zip(., file_match, unzip_dir))

      asc_path = glue::glue("{unzip_dir}/")
    }

    grid_files <- list.files(asc_path, file_match)

    #Load all terrain files in input directory
    raster_layers <- tibble::tibble(filename = grid_files)

    message("Merging files...")

    #Intialise a raster to merge in the rest of the files one at a time. Can't do it all at once due to memory issues.
    raster_mosaic <-
      raster::raster(glue::glue(
        "{asc_path}{raster_layers$filename[1]}"
      ))

    pb <- progress::progress_bar$new(total = nrow(raster_layers)-1)

    #Merge layers one at a time
    for (i in 2:nrow(raster_layers)) {
      new_raster <-
        raster::raster(glue::glue(
          "{asc_path}{raster_layers$filename[i]}"
        ))

      raster_mosaic <-
        raster::mosaic(raster_mosaic, new_raster, fun = "mean")

      pb$tick()

    }

    unlink(unzip_dir, recursive = TRUE)  #kill the temp directory containing .asc files

    message("Projecting raster...")

    raster::crs(raster_mosaic) <- "+init=epsg:27700"

    raster_mosaic = raster::projectRaster(raster_mosaic, crs = "+proj=longlat +datum=WGS84 +no_defs")

    raster::writeRaster(raster_mosaic, raster_output_file, overwrite = TRUE)

    message("Done")

    return(TRUE)

  }
