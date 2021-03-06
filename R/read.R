#' @export
syn_get_curated_data <- function(id) {
  query <- glue::glue("select * from {id}")
  path <- suppressMessages(synapser::synTableQuery(query)$filepath)
  return(read_curated_data(path))
}

#' @export
read_curated_data <- function(path) {
  d <- readr::read_csv(path, col_types = readr::cols()) %>%
    assertr::chain_start() %>%
    assertr::verify(assertr::has_all_names("Experiment",
                                           "Well",
                                           "ObjectLabelsFound",
                                           "ObjectTrackID",
                                           "TimePoint",
                                           "ObjectCount",
                                           "Mistracked",
                                           "Out_of_Focus",
                                           "Lost_Tracking",
                                           "XCoordinate",
                                           "YCoordinate")) %>%
    dplyr::mutate(XCoordinate = as.numeric(XCoordinate),
                  YCoordinate = as.numeric(YCoordinate),
                  Mistracked = as.logical(Mistracked),
                  Live_Cells = as.logical(Live_Cells),
                  Out_of_Focus = as.logical(Out_of_Focus),
                  Lost_Tracking = as.logical(Lost_Tracking))
  return(d)
}

#' @export
syn_get_image_masks <- function(id) {
  query <- glue::glue("select id,Experiment,Well,PID,parentId from {id}")
  d <- suppressMessages(synapser::synTableQuery(query))$asDataFrame() %>%
    tibble::as_tibble() %>%
    select(-ROW_ID, -ROW_VERSION, -ROW_ETAG)
  return(d)
}

#' @export
syn_get_tracking_metadata <- function(id) {
  query <- glue::glue("select * from {id}")
  d <- suppressMessages(synapser::synTableQuery(query))$asDataFrame() %>%
    tibble::as_tibble() %>%
    select(-ROW_ID, -ROW_VERSION) %>%
    dplyr::mutate(CurationFiles = as.logical(CurationFiles),
                  CellMasks = as.logical(CellMasks),
                  AlignedImages = as.logical(AlignedImages)
    )
  return(d)
}

#' Get a submitted tracking file
#'
#' @param id Synapse ID of a tracking CSV file.
#'
#' @export
syn_get_tracking_submission_file <- function(id) {
  o <- synapser::synGet(id)

  trackingResults <- read_tracking_submission_file(o$path)

  return(trackingResults)
}

#' Read a submitted tracking file
#'
#' @param path File path to a tracking CSV file.
#'
#' @export
read_tracking_submission_file <- function(path) {
  trackingResults <- readr::read_csv(path, col_types = readr::cols()) %>%
    assertr::verify(assertr::has_all_names("Experiment", "ObjectLabelsFound",
                                           "ObjectTrackID",  "Well", "TimePoint"))
  return(trackingResults)
}
