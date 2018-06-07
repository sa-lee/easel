# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ...) {
  update <- NextMethod()
  build_plibble(update, attr(.data, "aes_vars"))
}

mutate.tbl_pl_list <- function(.data, ...) {
  stack_pos <- length(.data)
  .data[[stack_pos]] <- mutate(.data[[stack_pos]], ...)
  .data
}
