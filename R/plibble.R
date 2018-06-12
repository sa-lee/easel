# simple approach just augment the data with aesthetics
# could do this either via nesting calls or tacking on 
# aesthetics to the input tibble/data.frame
build_plibble <- function(aes_tbl, aes_vars, call_list) {
  tibble::new_tibble(
    aes_tbl,
    mapping = aes_vars,
    pipeline = call_list,
    subclass = "tbl_pl"
  )
}

update_plibble <- function(x, mapping, call) {
  if (!missing(call)) {
    x <- set_pipeline(x, call)
  }
  
  if (!missing(mapping)) {
    x <- set_mapping(x, mapping)
  }
  x
}

is_plibble <- function(x) inherits(x, "tbl_pl")

#' @export
get_mapping <- function(x) { attr(x, "mapping") }
set_mapping <- function(x, mapping) { 
  attr(x, "mapping") <- mapping 
  x
}

strip_mapping <- function(x) { sub("aes_", "", x) }

set_pipeline <- function(x, call) {
  pipeline <- attr(x, "pipeline")
  pipeline <- c(pipeline,  call)
  attr(x, "pipeline") <- pipeline
  x
}

get_pipeline <- function(x) {
  attr(x, "pipeline")
}
#' @export 
visualise <- function(.data, ...) {
  mappings <- rlang::enquos(..., .named = TRUE)
  call <- function(.data) {
    # append "aes" to variable names
    mapping <- get_mapping(.data)
    aes_vars <- mapping
    names(aes_vars) <- paste0("aes_", names(aes_vars))
    # need to include checks for validity here
    .tbl <- dplyr::mutate(tibble::as_tibble(.data), rlang::UQS(aes_vars))
    build_plibble(.tbl, mapping, get_pipeline(.data))
  }
  
  build_plibble(.data, mappings, list(visualise = call))
}
