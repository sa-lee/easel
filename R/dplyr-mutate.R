# mutate.R
#' @importFrom dplyr mutate
#' @export
dplyr::mutate 

#' @method mutate tbl_pl
#' @export
mutate.tbl_pl <- function(.data, ..., update_aes = FALSE) {
  update <- NextMethod()
  aes <- attr(.data, "aes")
  if (update_aes) {
    aes_new <- rlang::enquos(..., .named = TRUE)
    update <- intersect(names(aes), names(aes_new))
    if (length(update) == 0L) {
      aes <- rlang::quos(rlang::UQS(aes), rlang::UQS(aes_new))
    } else {
      aes_old <- aes[setdiff(names(aes), names(aes_new))]
      aes <- rlang::quos(rlang::UQS(aes_old), rlang::UQS(aes_new))
    }
  }
  build_plibble(update, aes)
}

