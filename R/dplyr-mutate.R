# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  update_plibble(update, get_mapping(.data))
}