#' Stitches together files into a single raster
#' Requires a target directory of files that can be read with raster::raster(), e.g. .asc files, or a directory of .zip files containing these files
#'
#' @param path path to files that are to be stitched together
#' @param extract_zip \code{FALSE} to target .asc files, \code{TRUE} if your .asc files are zipped.
#' @param file_match regex pattern to match .asc files, either in \code{path} or in zip files.
#' @param zip_file_match regex pattern to match .zip files
#' @param raster_output_file raster file to be created (will overwrite existing files)
#' @param file_crs projection string of the input files. Output will always be WGS84.
#' @param raster_todisk Setting \code{TRUE} will set \code{rasterOptions(todisk=TRUE)}, which can help with memory issues.
#'
#' @return TRUE
#'
#' @examples
#' # Merges two small example .asc files of LIDAR data
#' # from https://environment.data.gov.uk (open government licence)
#'
#' path_to_files <- system.file("extdata/example_asc", package = "geoviz")
#'
#' path_to_output <- tempdir()
#'
#' mosaic_files(path_to_files,
#'              raster_output_file = paste0(path_to_output, '/mosaic_out.raster', sep = ''),
#'              extract_zip = TRUE, file_crs = "+init=epsg:27700")
#'
#' raster_mosaic <- raster::raster(paste0(path_to_output, '/mosaic_out.gri', sep = ''))
#' @export
mosaic_files <-
  function(path,
           extract_zip = FALSE,
           file_match = ".*.asc",
           zip_file_match = ".*.zip",
           raster_output_file = "mosaic_out.raster",
           file_crs = NULL,
           raster_todisk = FALSE) {
    if (substr(path, nchar(path), nchar(path)) != "/") {
      path <- glue::glue("{path}/")
    }

    if(raster_todisk){raster::rasterOptions(todisk=TRUE)}

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
        tibble::tibble(zip_files = list.files(path, zip_file_match, full.names = TRUE)) %>%
        dplyr::pull("zip_files") %>%
        purrr::walk(.f = ~  read_from_zip(., file_match, unzip_dir))

      path = glue::glue("{unzip_dir}/")
    }

    grid_files <- list.files(path, file_match)

    if(length(grid_files)==0){stop(glue::glue("No files found matching {file_match}"))}

    #Load all terrain files in input directory
    raster_layers <- tibble::tibble(filename = grid_files)

    message("Merging files...")

    #Intialise a raster to merge in the rest of the files one at a time. Can't do it all at once due to memory issues.
    raster_mosaic <-
      raster::raster(glue::glue(
        "{path}{raster_layers$filename[1]}"
      ))

    if(is.na(raster::crs(raster_mosaic))){
      if(is.null(file_crs)){stop("Input files have no CRS, use the file_crs option to set it")}
      raster::crs(raster_mosaic) <- file_crs
    }

    pb <- progress::progress_bar$new(total = nrow(raster_layers)-1)

    #Merge additional layers one at a time
    if(nrow(raster_layers) > 1){
      for (i in 2:nrow(raster_layers)) {
        new_raster <-
          raster::raster(glue::glue(
            "{path}{raster_layers$filename[i]}"
          ))

        if(is.na(raster::crs(raster_mosaic))){
          raster::crs(new_raster) <- file_crs
        }

        raster_mosaic <-
          raster::mosaic(raster_mosaic, new_raster, fun = "mean")

        pb$tick()
      }
    }

    raster::writeRaster(raster_mosaic, raster_output_file, overwrite = TRUE)

    if(extract_zip){unlink(unzip_dir, recursive = TRUE)}  #kill the temp directory if unzipping

    message("Done")

    return(TRUE)

  }
