# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  update_plibble(update, get_mapping(.data), get_pipeline(.data))
}


# modify a specific layer in place
mutate_at_layer <- function(.data, node, ...) {
  .data[[node]] <- mutate(.data[[node]], ...)
  .data
}