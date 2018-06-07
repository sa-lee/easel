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
    aes = aes_vars,
    subclass = "tbl_pl"
  )
}

#' @export 
plibble <- function(.data, ..., .inherit = TRUE) { UseMethod("plibble") }

#' @method plibble data.frame
#' @export 
plibble.data.frame <- function(.data, ..., .inherit = TRUE) {
  aes_vars <- rlang::enquos(..., .named = TRUE)
  aes_names <- rlang::syms(names(aes_vars))
  # need to include checks for validity here
  .data <- dplyr::mutate(tibble::as_tibble(.data), rlang::UQS(aes_vars))
  .data <- tidyr::nest(.data, rlang::UQS(aes_names), .key = "aes")
  build_plibble(.data, aes_vars)
}

plibble.tbl_pl <- function(.data, ..., .inherit = TRUE) {
  aes_vars <- rlang::enquos(..., .named = TRUE)
  if (.inherit) {
    aes_vars <- c(attr(.data, "aes"), aes_vars)
  } 
  layer_list <- plibble_list(list(.data)) 
  class(.data) <- c("tbl_df", "tbl", "data.frame")
  layer_list[[2]] <- plibble(dplyr::select(.data, -aes),  
                             rlang::UQS(aes_vars))
  layer_list
}

is_plibble <- function(x) inherits(x, "tbl_pl")

# a list of layers ...
plibble_list <- function(x) {
  stopifnot(all(vapply(x, is_plibble, logical(1))),
            is.list(x))
  structure(x, class = "tbl_pl_list", names = names(x))
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
get_aes <- function(x)  UseMethod("get_aes") 

get_aes.tbl_pl <- function(x) names(x[["aes"]][[1]])

get_aes.tbl_pl_list <- function(x) {
  stack_pos <- length(x)
  get_aes(x[[stack_pos]])
}

#' @export
get_layer_data <- function(x) UseMethod("get_layer_data") 
get_layer_data.tbl_pl <- function(x) dplyr::bind_rows(x[["aes"]])
