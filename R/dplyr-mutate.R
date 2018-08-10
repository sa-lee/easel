# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @importFrom dplyr transmute
#' @export
dplyr::transmute


#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  update_plibble(update, get_mapping(.data), get_pipeline(.data))
}

#' @method transmute tbl_pl
transmute.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  build_plibble(update, get_mapping(.data), get_pipeline(.data))
}


# modify a specific layer in place
mutate_at_layer <- function(.data, node, ...) {
  .data[[node]] <- mutate(.data[[node]], ...)
  .data
}