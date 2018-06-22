#' @export 
visualise <- function(.data, ...) UseMethod("visualise")

visualize <- visualise

visualise.data.frame <- function(.data, ...) {
  .data <- tibble::as_tibble(.data)
  mappings <- rlang::enquos(..., .named = TRUE)
  build_plibble(.data, mappings, list(visualise = .visualise))
}

visualise.mutibble <- function(.data, ...) {
  .data$.tbl <- visualise(.data$.tbl, ...)
  .data
}

.visualise <- function(.data) {
  # append "aes" to variable names
  mapping <- get_mapping(.data)
  aes_vars <- mapping
  names(aes_vars) <- paste0("aes_", names(aes_vars))
  # need to include checks for validity here
  dplyr::mutate(.data, rlang::UQS(aes_vars))
}