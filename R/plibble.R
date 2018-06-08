#' @export 
visualise <- function(.data, ..., .inherit = TRUE) {
  plibble(.data, ...)
}

# simple approach just augment the data with aesthetics
# could do this either via nesting calls or tacking on 
# aesthetics to the input tibble/data.frame
build_plibble <- function(aes_tbl, aes_vars) {
  tibble::new_tibble(
    aes_tbl,
    aes_vars = aes_vars,
    subclass = "tbl_pl"
  )
}

#' @export 
plibble <- function(.data, ...) { UseMethod("plibble") }

#' @export 
plibble.default <- function(.data, ...) {
  plibble.data.frame(tibble::as_data_frame(.data))
}
#' @method plibble data.frame
#' @export 
plibble.data.frame <- function(.data, ...) {
  aes_vars <- rlang::enquos(..., .named = TRUE)
  aes_names <- rlang::syms(names(aes_vars))
  # need to include checks for validity here
  .data <- dplyr::mutate(tibble::as_tibble(.data), rlang::UQS(aes_vars))
  .data <- tidyr::nest(.data, rlang::UQS(aes_names), .key = "aes")
  build_plibble(.data, aes_vars)
}

is_plibble <- function(x) inherits(x, "tbl_pl")

#' @export
get_aes <- function(x)  UseMethod("get_aes") 
get_aes.tbl_pl <- function(x) names(x[["aes"]][[1]])

get_quos_names <- function(quos) vapply(quos, rlang::quo_name, character(1))
# a list of layers ...
plibble_list <- function(x) {
  stopifnot(all(vapply(x, is_plibble, logical(1))),
            is.list(x))
  structure(x, class = "tbl_pl_list", names = names(x))
}

# put them together with mesh 
#' @export 
mesh <- function(...) {
  plibble_list(list(...))
}

#' @export
`[.tbl_pl_list` <- function(x, i) {
  structure(NextMethod(), class = "tbl_pl_list")
}
#' @export
c.tbl_pl_list <- function(..., recursive = FALSE) {
  plibble_list(NextMethod())
}



#' @export
get_layer_data <- function(x) UseMethod("get_layer_data") 
#' @export 
get_layer_data.tbl_pl <- function(x) dplyr::bind_rows(x[["aes"]])
